import 'package:drift/drift.dart';

import 'connection/database_connection.dart';
import 'daos/boxes_dao.dart';
import 'daos/items_dao.dart';
import 'demo_seed.dart';
import 'tables/boxes_table.dart';
import 'tables/items_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Boxes, Items], daos: [BoxesDao, ItemsDao])
class AppDatabase extends _$AppDatabase {
  /// Production constructor: opens the platform on-device connection.
  AppDatabase() : super(openConnection());

  /// Test/override constructor: inject any executor, e.g.
  /// `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // Enforce FK constraints so deleting a box cascades to its items.
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (m) async {
          await m.createAll();
          // Seed the single default box the MVP UI shows.
          final now = DateTime.now();
          final boxId = await into(boxes).insert(
            BoxesCompanion.insert(
              name: const Value('Treasure Box'),
              capacity: const Value(27),
              nfcTagId:
                  kDemoSeed ? const Value('0x4F9A2B1C') : const Value(null),
              qrToken: Value(slotCode(1)),
              slot: const Value(1),
              createdAt: now,
              updatedAt: now,
            ),
          );
          // Demo-only sample items; no-op unless built with --dart-define=DEMO.
          if (kDemoSeed) {
            for (final row in demoItemRows(boxId, now)) {
              await into(items).insert(row);
            }
            // A second box so the room shows multiple chests and find-my-stuff
            // has cross-box results.
            final box2Id = await into(boxes).insert(
              BoxesCompanion.insert(
                name: const Value('Storage Bin'),
                capacity: const Value(27),
                skinKey: const Value('trapped'),
                sortOrder: const Value(1),
                qrToken: Value(slotCode(2)),
                slot: const Value(2),
                createdAt: now,
                updatedAt: now,
              ),
            );
            for (final row in demoSecondBoxItemRows(box2Id, now)) {
              await into(items).insert(row);
            }
          }
        },
      );
}

/// The human identity code for a slot: `BOX-1`, `BOX-2`, ... This exact
/// string is what the printed QR encodes, what an NFC payload carries, and
/// what a person types - one code, three rails.
String slotCode(int slot) => 'BOX-$slot';
