import 'package:drift/drift.dart';

import '../app_database.dart' as db;
import '../backup/backup_codec.dart';
import '../daos/boxes_dao.dart';
import '../daos/items_dao.dart';
import '../models/box.dart';
import '../models/box_code.dart';
import '../models/item.dart';
import '../models/item_category.dart';
import '../models/rarity.dart';
import 'inventory_repository.dart';

/// Drift-backed implementation of [InventoryRepository]. This is the only place
/// that maps between generated Drift rows and the app's domain models.
class DriftInventoryRepository implements InventoryRepository {
  DriftInventoryRepository(this._db);

  final db.AppDatabase _db;

  ItemsDao get _items => _db.itemsDao;
  BoxesDao get _boxes => _db.boxesDao;

  Item _toItem(db.ItemRow row) => Item(
        id: row.id,
        boxId: row.boxId,
        name: row.name,
        category: ItemCategory.fromName(row.category),
        iconKey: row.iconKey,
        photoPath: row.photoPath,
        qty: row.qty,
        rarity: Rarity.fromName(row.rarity),
        notes: row.notes,
        spot: row.spot,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  Box _toBox(db.BoxRow row) => Box(
        id: row.id,
        name: row.name,
        capacity: row.capacity,
        nfcTagId: row.nfcTagId,
        qrToken: row.qrToken,
        slot: row.slot,
        skinKey: row.skinKey,
        sortOrder: row.sortOrder,
        qrUsedAt: row.qrUsedAt,
        nfcUsedAt: row.nfcUsedAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  @override
  Stream<List<Item>> watchItems(int boxId) {
    return _items
        .watchItemsForBox(boxId)
        .map((rows) => rows.map(_toItem).toList());
  }

  @override
  Future<Item?> getItem(int id) async {
    final row = await _items.getItem(id);
    return row == null ? null : _toItem(row);
  }

  @override
  Future<Item> upsertItem(int boxId, ItemDraft draft) async {
    final now = DateTime.now();
    if (draft.isNew) {
      final id = await _items.insertItem(
        db.ItemsCompanion.insert(
          boxId: boxId,
          name: draft.name,
          category: draft.category.name,
          iconKey: draft.iconKey,
          photoPath: Value(draft.photoPath),
          qty: Value(draft.qty),
          rarity: Value(draft.rarity.name),
          notes: Value(draft.notes),
          spot: Value(draft.spot),
          createdAt: now,
          updatedAt: now,
        ),
      );
      final row = await _items.getItem(id);
      return _toItem(row!);
    }

    // Update: preserve createdAt, refresh updatedAt.
    final existing = await _items.getItem(draft.id!);
    await _items.updateItem(
      db.ItemsCompanion(
        id: Value(draft.id!),
        boxId: Value(boxId),
        name: Value(draft.name),
        category: Value(draft.category.name),
        iconKey: Value(draft.iconKey),
        photoPath: Value(draft.photoPath),
        qty: Value(draft.qty),
        rarity: Value(draft.rarity.name),
        notes: Value(draft.notes),
        spot: Value(draft.spot),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
    final row = await _items.getItem(draft.id!);
    return _toItem(row!);
  }

  @override
  Future<void> deleteItem(int id) => _items.deleteItem(id);

  @override
  Future<int> slotCount(int boxId) => _items.countForBox(boxId);

  @override
  Stream<List<Box>> watchBoxes() =>
      _boxes.watchBoxes().map((rows) => rows.map(_toBox).toList());

  @override
  Stream<Box> watchBox(int id) => _boxes.watchBox(id).map(_toBox);

  @override
  Future<Box> currentBox() async => _toBox(await _boxes.getOrCreateDefaultBox());

  @override
  Future<Box> createBox({String name = 'New Box', String skinKey = 'oak'}) async =>
      _toBox(await _boxes.createBox(name: name, skinKey: skinKey));

  @override
  Future<void> renameBox(int id, String name) => _boxes.renameBox(id, name);

  @override
  Future<void> setCapacity(int id, int capacity) =>
      _boxes.setCapacity(id, capacity);

  @override
  Future<void> setSkin(int id, String skinKey) => _boxes.setSkin(id, skinKey);

  @override
  Future<void> setNfcTag(int id, String? tagId) => _boxes.setNfcTag(id, tagId);

  @override
  Future<void> deleteBox(int id) => _boxes.deleteBox(id);

  @override
  Future<Box?> boxByToken(String token) async {
    final row = await _boxes.boxByToken(token);
    return row == null ? null : _toBox(row);
  }

  @override
  Future<Box?> boxByAnyCode(String code) async {
    // Strip any rail envelope (TB:BOX-1:QR) or deep-link path first.
    final raw = parseBoxCode(code).code;
    if (raw.isEmpty) return null;
    final upper = raw.toUpperCase();

    final all = await _boxes.allBoxes();

    // Canonical: the BOX-N code (as printed / written to the tag).
    for (final b in all) {
      if ((b.qrToken ?? '').toUpperCase() == upper) return _toBox(b);
    }
    // A bare slot number ("3" on a marker label means BOX-3).
    final asNum = int.tryParse(raw);
    if (asNum != null) {
      for (final b in all) {
        if (b.slot == asNum) return _toBox(b);
      }
    }
    // Exact name, case-insensitive.
    final lower = raw.toLowerCase();
    for (final b in all) {
      if (b.name.toLowerCase() == lower) return _toBox(b);
    }
    return null;
  }

  @override
  Future<void> markOpenedVia(int boxId, BoxCodeSource source) {
    final now = DateTime.now();
    switch (source) {
      case BoxCodeSource.qr:
        return _boxes.markOpened(boxId, viaQr: now);
      case BoxCodeSource.nfc:
        return _boxes.markOpened(boxId, viaNfc: now);
      case BoxCodeSource.id:
        return Future.value(); // Typed codes always work; nothing to learn.
    }
  }

  @override
  Stream<List<FoundItem>> watchRecentItems(int limit) {
    return _items.watchRecentItems(limit).asyncMap((rows) async {
      final boxRows = await _boxes.allBoxes();
      final boxById = {for (final b in boxRows) b.id: _toBox(b)};
      return [
        for (final row in rows)
          if (boxById[row.boxId] != null)
            FoundItem(item: _toItem(row), box: boxById[row.boxId]!),
      ];
    });
  }

  @override
  Future<void> clearBox(int id) => _boxes.clearBox(id);

  @override
  Future<List<FoundItem>> findItems(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final boxRows = await _boxes.allBoxes();
    final boxById = {for (final b in boxRows) b.id: _toBox(b)};
    final rows = await _items.allItems();
    final matches = <FoundItem>[];
    for (final row in rows) {
      final item = _toItem(row);
      final hit = item.name.toLowerCase().contains(q) ||
          item.category.label.toLowerCase().contains(q) ||
          (item.notes?.toLowerCase().contains(q) ?? false) ||
          (item.spot?.toLowerCase().contains(q) ?? false);
      if (hit && boxById[item.boxId] != null) {
        matches.add(FoundItem(item: item, box: boxById[item.boxId]!));
      }
    }
    matches.sort((a, b) =>
        a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase()));
    return matches;
  }

  @override
  Future<Backup> exportBackup() async {
    final boxRows = await _boxes.allBoxes();
    final itemRows = await _items.allItems();
    final itemsByBox = <int, List<Item>>{};
    for (final row in itemRows) {
      itemsByBox.putIfAbsent(row.boxId, () => []).add(_toItem(row));
    }
    return Backup(
      exportedAt: DateTime.now(),
      boxes: [
        for (final b in boxRows)
          BoxBackup(box: _toBox(b), items: itemsByBox[b.id] ?? const []),
      ],
    );
  }

  @override
  Future<int> importBackup(List<ImportedBox> imported) async {
    var written = 0;
    // One transaction: a failed import never leaves half a backup behind.
    await _db.transaction(() async {
      for (final ib in imported) {
        // Match by slot code so re-importing a backup is idempotent.
        final code = db.slotCode(ib.slot);
        final existingRow =
            ib.slot > 0 ? await _boxes.boxByToken(code) : null;
        final int boxId;
        if (existingRow != null) {
          boxId = existingRow.id;
        } else {
          final created = await _boxes.createBox(
            name: ib.name,
            skinKey: ib.skinKey,
            preferredSlot: ib.slot,
          );
          boxId = created.id;
          if (ib.capacity != 27) {
            await _boxes.setCapacity(boxId, ib.capacity);
          }
        }

        // Merge items, skipping ones the box already holds (same name).
        final existingNames = {
          for (final row in await _items.allItems())
            if (row.boxId == boxId) row.name.toLowerCase(),
        };
        for (final draft in ib.items) {
          if (existingNames.contains(draft.name.toLowerCase())) continue;
          await upsertItem(boxId, draft);
          written++;
        }
      }
    });
    return written;
  }
}
