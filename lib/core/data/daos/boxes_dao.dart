import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/boxes_table.dart';
import '../tables/items_table.dart';

part 'boxes_dao.g.dart';

@DriftAccessor(tables: [Boxes, Items])
class BoxesDao extends DatabaseAccessor<AppDatabase> with _$BoxesDaoMixin {
  BoxesDao(super.db);

  /// Watch a single box by id.
  Stream<BoxRow> watchBox(int id) {
    return (select(boxes)..where((b) => b.id.equals(id))).watchSingle();
  }

  /// Watch all boxes, ordered for display.
  Stream<List<BoxRow>> watchBoxes() {
    return (select(boxes)
          ..orderBy([
            (b) => OrderingTerm(expression: b.sortOrder),
            (b) => OrderingTerm(expression: b.id),
          ]))
        .watch();
  }

  Future<List<BoxRow>> allBoxes() {
    return (select(boxes)
          ..orderBy([
            (b) => OrderingTerm(expression: b.sortOrder),
            (b) => OrderingTerm(expression: b.id),
          ]))
        .get();
  }

  /// Return the first box, creating a default one (with a token) if empty.
  Future<BoxRow> getOrCreateDefaultBox() async {
    final existing = await (select(boxes)..limit(1)).getSingleOrNull();
    if (existing != null) return existing;
    return createBox(name: 'Treasure Box');
  }

  /// Create a new box in the lowest free identity slot. Slots are reused
  /// after deletion (delete BOX-2, the next box IS BOX-2 again), so printed
  /// QR labels and written NFC tags survive box turnover.
  Future<BoxRow> createBox({
    String name = 'New Box',
    String skinKey = 'oak',
  }) async {
    final now = DateTime.now();
    final count = await boxCount();
    final slot = await _lowestFreeSlot();
    final id = await into(boxes).insert(
      BoxesCompanion.insert(
        name: Value(name),
        capacity: const Value(27),
        sortOrder: Value(count),
        qrToken: Value(slotCode(slot)),
        slot: Value(slot),
        skinKey: Value(skinKey),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return (select(boxes)..where((b) => b.id.equals(id))).getSingle();
  }

  Future<int> _lowestFreeSlot() async {
    final rows = await (selectOnly(boxes)..addColumns([boxes.slot])).get();
    final used = rows.map((r) => r.read(boxes.slot) ?? 0).toSet();
    var slot = 1;
    while (used.contains(slot)) {
      slot++;
    }
    return slot;
  }

  Future<int> boxCount() async {
    final c = boxes.id.count();
    final row = await (selectOnly(boxes)..addColumns([c])).getSingle();
    return row.read(c) ?? 0;
  }

  Future<BoxRow?> boxByToken(String token) {
    return (select(boxes)..where((b) => b.qrToken.equals(token)))
        .getSingleOrNull();
  }

  Future<void> renameBox(int id, String name) {
    return (update(boxes)..where((b) => b.id.equals(id))).write(
      BoxesCompanion(name: Value(name), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> setCapacity(int id, int capacity) {
    return (update(boxes)..where((b) => b.id.equals(id))).write(
      BoxesCompanion(
        capacity: Value(capacity),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setSkin(int id, String skinKey) {
    return (update(boxes)..where((b) => b.id.equals(id))).write(
      BoxesCompanion(
        skinKey: Value(skinKey),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setNfcTag(int id, String? tagId) {
    return (update(boxes)..where((b) => b.id.equals(id))).write(
      BoxesCompanion(
        nfcTagId: Value(tagId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Stamp a rail-usage timestamp (auto-learned badges). Pass exactly one.
  Future<void> markOpened(int id, {DateTime? viaQr, DateTime? viaNfc}) {
    return (update(boxes)..where((b) => b.id.equals(id))).write(
      BoxesCompanion(
        qrUsedAt: viaQr == null ? const Value.absent() : Value(viaQr),
        nfcUsedAt: viaNfc == null ? const Value.absent() : Value(viaNfc),
      ),
    );
  }

  /// Delete the box (items cascade via the FK).
  Future<void> deleteBox(int id) {
    return (delete(boxes)..where((b) => b.id.equals(id))).go();
  }

  /// Delete every item in the box (does not delete the box itself).
  Future<void> clearBox(int id) {
    return (delete(items)..where((i) => i.boxId.equals(id))).go();
  }
}
