import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens a browser-backed SQLite database using the WASM build of sqlite3.
///
/// Requires `sqlite3.wasm` and `drift_worker.js` in the web root (they live in
/// `web/`). Storage persists in the browser (OPFS / IndexedDB) when available;
/// if neither the assets nor a persistent store are available, drift falls back
/// to an in-memory database so the app still runs.
QueryExecutor openPlatformConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'treasure_box',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
