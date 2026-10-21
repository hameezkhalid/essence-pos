// Compiled to web/drift_worker.js (see README): runs the browser database in a web worker.
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
