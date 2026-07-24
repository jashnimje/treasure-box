import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';

/// The app database. Overridden in tests with an in-memory instance
/// (`AppDatabase.forTesting(NativeDatabase.memory())`).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
