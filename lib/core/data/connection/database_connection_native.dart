import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens a file-backed SQLite database in the app documents directory.
QueryExecutor openPlatformConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'treasure_box.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
