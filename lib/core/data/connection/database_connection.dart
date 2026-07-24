import 'package:drift/drift.dart';

// Chooses the platform-specific opener at compile time: the native
// implementation on mobile/desktop, the web (wasm) implementation in a browser.
import 'database_connection_native.dart'
    if (dart.library.js_interop) 'database_connection_web.dart';

/// Opens the default on-device database connection for the current platform.
QueryExecutor openConnection() => openPlatformConnection();
