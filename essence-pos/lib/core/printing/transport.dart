import 'dart:typed_data';

import 'printer_config.dart';
import 'transport_stub.dart' if (dart.library.io) 'transport_io.dart' as impl;

/// Sends raw ESC/POS bytes to a printer.
Future<void> sendToPrinter(PrinterConfig printer, Uint8List bytes) => impl.sendBytes(printer, bytes);

/// Printers installed on this computer (Windows spooler / CUPS). Empty where unsupported.
Future<List<String>> listSystemPrinters() => impl.listSystemPrinters();

/// The printer kind to suggest on this platform.
PrinterKind defaultPrinterKind() => impl.defaultKind();

bool get printingSupported => impl.supported;
