import 'dart:typed_data';

import 'printer_config.dart';

const supported = false;

Future<void> sendBytes(PrinterConfig printer, Uint8List bytes) async =>
    throw UnsupportedError('Printing is available in the desktop and Android apps');

Future<List<String>> listSystemPrinters() async => const [];

PrinterKind defaultKind() => PrinterKind.network;
