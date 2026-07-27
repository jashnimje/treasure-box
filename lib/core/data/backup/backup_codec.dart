import 'dart:convert';

import '../models/box.dart';
import '../models/item.dart';
import '../models/item_category.dart';
import '../models/rarity.dart';

/// One box with its items, as captured by an export.
class BoxBackup {
  const BoxBackup({required this.box, required this.items});

  final Box box;
  final List<Item> items;
}

/// A full backup: every box and every item, plus format metadata.
class Backup {
  const Backup({required this.exportedAt, required this.boxes});

  final DateTime exportedAt;
  final List<BoxBackup> boxes;

  int get itemCount => boxes.fold(0, (sum, b) => sum + b.items.length);
}

/// The JSON backup format version. Bump only on breaking changes;
/// readers accept any version they know how to parse.
const int kBackupFormatVersion = 1;

/// Encodes a [Backup] as pretty-printed JSON - the full-fidelity format
/// (photos excepted: paths are device-local and are not portable).
String encodeBackupJson(Backup backup) {
  return const JsonEncoder.withIndent('  ').convert({
    'app': 'treasure_box',
    'format': kBackupFormatVersion,
    'exportedAt': backup.exportedAt.toIso8601String(),
    'boxes': [
      for (final b in backup.boxes)
        {
          'name': b.box.name,
          'code': b.box.code,
          'slot': b.box.slot,
          'capacity': b.box.capacity,
          'skinKey': b.box.skinKey,
          'items': [
            for (final i in b.items)
              {
                'name': i.name,
                'category': i.category.name,
                'iconKey': i.iconKey,
                'qty': i.qty,
                'rarity': i.rarity.name,
                if (i.notes != null) 'notes': i.notes,
                if (i.spot != null) 'spot': i.spot,
                'createdAt': i.createdAt.toIso8601String(),
              },
          ],
        },
    ],
  });
}

/// Raised when an import payload is not a Treasure Box backup.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

/// Parsed form of an imported backup, decoupled from live database ids.
class ImportedBox {
  const ImportedBox({
    required this.name,
    required this.slot,
    required this.capacity,
    required this.skinKey,
    required this.items,
  });

  final String name;
  final int slot;
  final int capacity;
  final String skinKey;
  final List<ItemDraft> items;
}

/// Decodes a JSON backup produced by [encodeBackupJson]. Throws
/// [BackupFormatException] on anything that is not a valid backup.
List<ImportedBox> decodeBackupJson(String source) {
  final dynamic root;
  try {
    root = json.decode(source);
  } on FormatException {
    throw const BackupFormatException('Not a JSON file');
  }
  if (root is! Map || root['app'] != 'treasure_box') {
    throw const BackupFormatException('Not a Treasure Box backup');
  }
  final boxesRaw = root['boxes'];
  if (boxesRaw is! List) {
    throw const BackupFormatException('Backup has no boxes');
  }

  final result = <ImportedBox>[];
  for (final b in boxesRaw) {
    if (b is! Map) continue;
    final itemsRaw = b['items'];
    final items = <ItemDraft>[];
    if (itemsRaw is List) {
      for (final i in itemsRaw) {
        if (i is! Map) continue;
        final name = i['name'];
        if (name is! String || name.isEmpty) continue;
        items.add(ItemDraft(
          name: name,
          category: ItemCategory.fromName(i['category'] as String?),
          iconKey: (i['iconKey'] as String?) ?? 'book',
          qty: (i['qty'] as num?)?.toInt() ?? 1,
          rarity: Rarity.fromName(i['rarity'] as String?),
          notes: i['notes'] as String?,
          spot: i['spot'] as String?,
        ));
      }
    }
    result.add(ImportedBox(
      name: (b['name'] as String?) ?? 'Imported Box',
      slot: (b['slot'] as num?)?.toInt() ?? 0,
      capacity: (b['capacity'] as num?)?.toInt() ?? 27,
      skinKey: (b['skinKey'] as String?) ?? 'oak',
      items: items,
    ));
  }
  if (result.isEmpty) {
    throw const BackupFormatException('Backup contains no boxes');
  }
  return result;
}

/// Encodes a [Backup] as CSV - one row per item, spreadsheet-friendly.
/// Lossy by design (no capacities or box styles); use JSON to restore.
String encodeBackupCsv(Backup backup) {
  final buf = StringBuffer()
    ..writeln('box,box_code,item,category,rarity,qty,spot,notes,added');
  for (final b in backup.boxes) {
    for (final i in b.items) {
      buf.writeln([
        b.box.name,
        b.box.code,
        i.name,
        i.category.label,
        i.rarity.label,
        '${i.qty}',
        i.spot ?? '',
        i.notes ?? '',
        i.createdAt.toIso8601String(),
      ].map(_csvCell).join(','));
    }
  }
  return buf.toString();
}

String _csvCell(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
