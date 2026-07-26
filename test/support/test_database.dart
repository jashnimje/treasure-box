import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:treasure_box/core/data/app_database.dart';
import 'package:treasure_box/core/providers/database_providers.dart';

/// A fresh in-memory database for a single test. No file I/O, deterministic.
AppDatabase makeTestDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());

/// A ProviderContainer whose [databaseProvider] is overridden with an in-memory
/// database. Dispose it in `addTearDown`.
ProviderContainer makeTestContainer(AppDatabase db) {
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db)],
  );
  return container;
}
