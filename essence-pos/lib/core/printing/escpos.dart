import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

import 'receipt_doc.dart';

/// Renders a [ReceiptDoc] to ESC/POS bytes for 58/80mm thermal printers.
class EscPosRenderer {
  EscPosRenderer({required this.columns, this.logoPng, this.nativeQr = true, this.dotsWidth = 576});

  /// Characters per line in Font A: 48 for 80mm, 32 for 58mm.
  final int columns;

  /// Printable width in dots: 576 for 80mm, 384 for 58mm.
  final int dotsWidth;
  final Uint8List? logoPng;

  /// Use the printer's QR command; when false the QR is sent as a raster image.
  final bool nativeQr;

  static const _esc = 0x1B;
  static const _gs = 0x1D;

  Uint8List render(ReceiptDoc doc) {
    final b = BytesBuilder();
    b.add([_esc, 0x40]); // init
    b.add([_esc, 0x74, 0x00]); // code page PC437
    for (final l in doc.lines) {
      switch (l) {
        case RText():
          _align(b, l.align);
          _bold(b, l.bold);
          _size(b, l.big ? 2 : 1, (l.big || l.tall) ? 2 : 1);
          final width = l.big ? columns ~/ 2 : columns;
          for (final line in wrapText(toPrintable(l.text), width)) {
            _text(b, line);
          }
          _size(b, 1, 1);
          _bold(b, false);
        case RRow():
          _align(b, RAlign.left);
          _bold(b, l.bold);
          _size(b, 1, l.tall ? 2 : 1);
          for (final line in layoutRow(toPrintable(l.left), toPrintable(l.right), columns, indent: l.indent)) {
            _text(b, line);
          }
          _size(b, 1, 1);
          _bold(b, false);
        case RDivider():
          _align(b, RAlign.left);
          _text(b, l.char * columns);
        case RQr():
          _align(b, RAlign.center);
          if (nativeQr) {
            _qrNative(b, l.data, l.size);
          } else {
            _raster(b, _qrBitmap(l.data, l.size));
          }
          _align(b, RAlign.left);
        case RLogo():
          final bmp = logoPng == null ? null : _logoBitmap(logoPng!);
          if (bmp != null) {
            _align(b, RAlign.center);
            _raster(b, bmp);
            _align(b, RAlign.left);
          }
        case RFeed():
          b.add([_esc, 0x64, l.lines.clamp(0, 10)]);
      }
    }
    if (doc.cut) {
      b.add([_esc, 0x64, 3]);
      b.add([_gs, 0x56, 0x42, 0x00]); // feed and partial cut
    }
    if (doc.openDrawer) b.add(drawerKick);
    return b.toBytes();
  }

  /// Pulse on drawer pin 2: ESC p 0 25 250.
  static const List<int> drawerKick = [_esc, 0x70, 0x00, 0x19, 0xFA];

  void _text(BytesBuilder b, String s) {
    b.add(latin1.encode(s));
    b.addByte(0x0A);
  }

  void _align(BytesBuilder b, RAlign a) => b.add([_esc, 0x61, a.index]);
  void _bold(BytesBuilder b, bool on) => b.add([_esc, 0x45, on ? 1 : 0]);
  void _size(BytesBuilder b, int w, int h) => b.add([_gs, 0x21, ((w - 1) << 4) | (h - 1)]);

  void _qrNative(BytesBuilder b, String data, int size) {
    final bytes = latin1.encode(toPrintable(data));
    final len = bytes.length + 3;
    b.add([_gs, 0x28, 0x6B, 4, 0, 0x31, 0x41, 0x32, 0x00]); // model 2
    b.add([_gs, 0x28, 0x6B, 3, 0, 0x31, 0x43, size.clamp(1, 16)]); // module size
    b.add([_gs, 0x28, 0x6B, 3, 0, 0x31, 0x45, 0x31]); // error correction M
    b.add([_gs, 0x28, 0x6B, len & 0xFF, (len >> 8) & 0xFF, 0x31, 0x50, 0x30, ...bytes]); // store
    b.add([_gs, 0x28, 0x6B, 3, 0, 0x31, 0x51, 0x30]); // print
    b.addByte(0x0A);
  }

  _Bitmap _qrBitmap(String data, int moduleDots) {
    final qr = QrImage(QrCode(payload: QrPayload.fromString(data)));
    final n = qr.moduleCount + 8; // quiet zone of 4 modules each side
    final px = n * moduleDots;
    final bmp = _Bitmap(px, px);
    for (var r = 0; r < qr.moduleCount; r++) {
      for (var c = 0; c < qr.moduleCount; c++) {
        if (!qr.isDark(r, c)) continue;
        for (var y = 0; y < moduleDots; y++) {
          for (var x = 0; x < moduleDots; x++) {
            bmp.set((c + 4) * moduleDots + x, (r + 4) * moduleDots + y);
          }
        }
      }
    }
    return bmp;
  }

  _Bitmap? _logoBitmap(Uint8List png) {
    final decoded = img.decodeImage(png);
    if (decoded == null) return null;
    final target = (dotsWidth * 0.42).round();
    final resized = img.copyResize(decoded, width: target, interpolation: img.Interpolation.average);
    final bmp = _Bitmap(resized.width, resized.height);
    for (var y = 0; y < resized.height; y++) {
      for (var x = 0; x < resized.width; x++) {
        final p = resized.getPixel(x, y);
        final lum = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
        final alpha = p.a / p.maxChannelValue;
        if (alpha > 0.5 && lum / p.maxChannelValue < 0.6) bmp.set(x, y);
      }
    }
    return bmp;
  }

  /// GS v 0: raster bit image.
  void _raster(BytesBuilder b, _Bitmap bmp) {
    final bytesPerRow = (bmp.width + 7) ~/ 8;
    b.add([_gs, 0x76, 0x30, 0x00, bytesPerRow & 0xFF, (bytesPerRow >> 8) & 0xFF, bmp.height & 0xFF, (bmp.height >> 8) & 0xFF]);
    b.add(bmp.pack());
    b.addByte(0x0A);
  }
}

class _Bitmap {
  _Bitmap(this.width, this.height) : _bits = List.filled(width * height, false);
  final int width;
  final int height;
  final List<bool> _bits;
  void set(int x, int y) {
    if (x >= 0 && y >= 0 && x < width && y < height) _bits[y * width + x] = true;
  }

  Uint8List pack() {
    final bytesPerRow = (width + 7) ~/ 8;
    final out = Uint8List(bytesPerRow * height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (_bits[y * width + x]) out[y * bytesPerRow + (x >> 3)] |= 0x80 >> (x & 7);
      }
    }
    return out;
  }
}
