import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;

import 'printer_config.dart';

const supported = true;

PrinterKind defaultKind() {
  if (Platform.isWindows) return PrinterKind.windows;
  if (Platform.isMacOS || Platform.isLinux) return PrinterKind.cups;
  return PrinterKind.network;
}

Future<void> sendBytes(PrinterConfig printer, Uint8List bytes) async {
  switch (printer.kind) {
    case PrinterKind.network:
      await _sendNetwork(printer.target, bytes);
    case PrinterKind.windows:
      if (!Platform.isWindows) throw UnsupportedError('Windows printers can only be used on Windows');
      _WinSpool.instance.writeRaw(printer.target, bytes);
    case PrinterKind.cups:
      if (!(Platform.isMacOS || Platform.isLinux)) throw UnsupportedError('System printers need macOS or Linux');
      await _sendCups(printer.target, bytes);
  }
}

Future<List<String>> listSystemPrinters() async {
  try {
    if (Platform.isWindows) return _WinSpool.instance.listPrinters();
    if (Platform.isMacOS || Platform.isLinux) {
      final r = await Process.run('lpstat', ['-e']);
      if (r.exitCode != 0) return const [];
      return (r.stdout as String).split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
  } catch (_) {}
  return const [];
}

Future<void> _sendNetwork(String target, Uint8List bytes) async {
  final parts = target.split(':');
  final host = parts.first.trim();
  final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 9100 : 9100;
  final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
  try {
    socket.add(bytes);
    await socket.flush();
  } finally {
    await socket.close();
    socket.destroy();
  }
}

Future<void> _sendCups(String printerName, Uint8List bytes) async {
  final dir = await Directory.systemTemp.createTemp('essence_print');
  final file = File(p.join(dir.path, 'job.bin'));
  await file.writeAsBytes(bytes, flush: true);
  try {
    final r = await Process.run('lp', ['-d', printerName, '-o', 'raw', file.path]);
    if (r.exitCode != 0) throw Exception('lp failed: ${r.stderr}');
  } finally {
    await dir.delete(recursive: true);
  }
}

// ───────────────────── Windows print spooler (winspool.drv) ─────────────────────

final class _DocInfo1 extends Struct {
  external Pointer<Utf16> pDocName;
  external Pointer<Utf16> pOutputFile;
  external Pointer<Utf16> pDatatype;
}

final class _PrinterInfo4 extends Struct {
  external Pointer<Utf16> pPrinterName;
  external Pointer<Utf16> pServerName;
  @Uint32()
  external int attributes;
}

typedef _OpenC = Int32 Function(Pointer<Utf16>, Pointer<IntPtr>, Pointer<Void>);
typedef _OpenD = int Function(Pointer<Utf16>, Pointer<IntPtr>, Pointer<Void>);
typedef _StartDocC = Uint32 Function(IntPtr, Uint32, Pointer<_DocInfo1>);
typedef _StartDocD = int Function(int, int, Pointer<_DocInfo1>);
typedef _HandleC = Int32 Function(IntPtr);
typedef _HandleD = int Function(int);
typedef _WriteC = Int32 Function(IntPtr, Pointer<Uint8>, Uint32, Pointer<Uint32>);
typedef _WriteD = int Function(int, Pointer<Uint8>, int, Pointer<Uint32>);
typedef _EnumC = Int32 Function(Uint32, Pointer<Utf16>, Uint32, Pointer<Uint8>, Uint32, Pointer<Uint32>, Pointer<Uint32>);
typedef _EnumD = int Function(int, Pointer<Utf16>, int, Pointer<Uint8>, int, Pointer<Uint32>, Pointer<Uint32>);

class _WinSpool {
  _WinSpool._() {
    final lib = DynamicLibrary.open('winspool.drv');
    _open = lib.lookupFunction<_OpenC, _OpenD>('OpenPrinterW');
    _startDoc = lib.lookupFunction<_StartDocC, _StartDocD>('StartDocPrinterW');
    _startPage = lib.lookupFunction<_HandleC, _HandleD>('StartPagePrinter');
    _write = lib.lookupFunction<_WriteC, _WriteD>('WritePrinter');
    _endPage = lib.lookupFunction<_HandleC, _HandleD>('EndPagePrinter');
    _endDoc = lib.lookupFunction<_HandleC, _HandleD>('EndDocPrinter');
    _close = lib.lookupFunction<_HandleC, _HandleD>('ClosePrinter');
    _enum = lib.lookupFunction<_EnumC, _EnumD>('EnumPrintersW');
  }

  static final instance = _WinSpool._();

  late final _OpenD _open;
  late final _StartDocD _startDoc;
  late final _HandleD _startPage;
  late final _WriteD _write;
  late final _HandleD _endPage;
  late final _HandleD _endDoc;
  late final _HandleD _close;
  late final _EnumD _enum;

  static const _enumLocal = 0x2;
  static const _enumConnections = 0x4;

  void writeRaw(String printerName, Uint8List data) {
    final name = printerName.toNativeUtf16(allocator: calloc);
    final handle = calloc<IntPtr>();
    final doc = calloc<_DocInfo1>();
    final docName = 'Essence POS'.toNativeUtf16(allocator: calloc);
    final dataType = 'RAW'.toNativeUtf16(allocator: calloc);
    final buf = calloc<Uint8>(data.length);
    final written = calloc<Uint32>();
    try {
      if (_open(name, handle, nullptr) == 0) throw Exception('Printer "$printerName" not found');
      final h = handle.value;
      try {
        doc.ref
          ..pDocName = docName
          ..pOutputFile = nullptr
          ..pDatatype = dataType;
        if (_startDoc(h, 1, doc) == 0) throw Exception('Could not start print job');
        _startPage(h);
        buf.asTypedList(data.length).setAll(0, data);
        final ok = _write(h, buf, data.length, written);
        _endPage(h);
        _endDoc(h);
        if (ok == 0 || written.value != data.length) throw Exception('Printer did not accept the data');
      } finally {
        _close(h);
      }
    } finally {
      calloc
        ..free(name)
        ..free(handle)
        ..free(doc)
        ..free(docName)
        ..free(dataType)
        ..free(buf)
        ..free(written);
    }
  }

  List<String> listPrinters() {
    final needed = calloc<Uint32>();
    final returned = calloc<Uint32>();
    try {
      _enum(_enumLocal | _enumConnections, nullptr, 4, nullptr, 0, needed, returned);
      if (needed.value == 0) return const [];
      final buf = calloc<Uint8>(needed.value);
      try {
        if (_enum(_enumLocal | _enumConnections, nullptr, 4, buf, needed.value, needed, returned) == 0) return const [];
        final infos = buf.cast<_PrinterInfo4>();
        return [for (var i = 0; i < returned.value; i++) infos[i].pPrinterName.toDartString()];
      } finally {
        calloc.free(buf);
      }
    } finally {
      calloc
        ..free(needed)
        ..free(returned);
    }
  }
}
