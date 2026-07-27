import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/data/backup/backup_codec.dart';
import '../../core/data/models/item.dart';
import '../../core/data/repositories/inventory_repository.dart';

/// When the last successful export happened, persisted locally. Null until
/// the first backup - the Settings screen nudges while it stays null.
class LastBackupNotifier extends Notifier<DateTime?> {
  static const _prefsKey = 'last_backup_at';

  @override
  DateTime? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_prefsKey);
    if (millis != null) {
      state = DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }

  Future<void> stamp() async {
    final now = DateTime.now();
    state = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, now.millisecondsSinceEpoch);
  }
}

final lastBackupProvider =
    NotifierProvider<LastBackupNotifier, DateTime?>(LastBackupNotifier.new);

/// Result of an export or import, for the snackbar.
class BackupOutcome {
  const BackupOutcome(this.message, {this.failed = false});

  final String message;
  final bool failed;
}

/// Export the whole inventory as ONE backup file - a zip holding
/// `backup.json` plus every item photo - and hand it to the system share
/// sheet. On Android that includes "Save to Drive", so Google Drive backups
/// need no cloud wiring.
Future<BackupOutcome> exportBackup(InventoryRepository repo) async {
  final backup = await repo.exportBackup();
  if (backup.boxes.isEmpty) {
    return const BackupOutcome('Nothing to export yet', failed: true);
  }

  final archive = Archive()
    ..add(ArchiveFile.string('backup.json', encodeBackupJson(backup)));

  // Pack the photos (device files - web has no local photos to pack).
  var photos = 0;
  if (!kIsWeb) {
    for (final b in backup.boxes) {
      for (final i in b.items) {
        if (!i.hasPhoto) continue;
        final file = File(i.photoPath!);
        if (!file.existsSync()) continue;
        archive.add(ArchiveFile.bytes(
          photoArchivePath(b.box.slot, i.id, i.photoPath!),
          await file.readAsBytes(),
        ));
        photos++;
      }
    }
  }

  final bytes = ZipEncoder().encode(archive);
  final stamp = backup.exportedAt
      .toIso8601String()
      .substring(0, 19)
      .replaceAll(':', '-');
  final name = 'treasure-box-$stamp.zip';

  final result = await SharePlus.instance.share(ShareParams(
    files: [
      XFile.fromData(
        Uint8List.fromList(bytes),
        name: name,
        mimeType: 'application/zip',
      ),
    ],
    fileNameOverrides: [name],
    subject: 'Treasure Box backup',
  ));
  if (result.status == ShareResultStatus.unavailable) {
    return const BackupOutcome('Sharing is not available here',
        failed: true);
  }
  return BackupOutcome(
      '${backup.itemCount} items and $photos photos exported');
}

/// Pick a backup (.zip, or a bare backup.json) - the picker browses Google
/// Drive too - and merge it in: boxes match by code, existing items are
/// never duplicated, and photos are restored to app storage.
Future<BackupOutcome> importBackup(InventoryRepository repo) async {
  final picked = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['zip', 'json'],
    withData: true,
  );
  final file = picked?.files.firstOrNull;
  final bytes = file?.bytes;
  if (file == null || bytes == null) {
    return const BackupOutcome('Import cancelled', failed: true);
  }

  try {
    final List<ImportedBox> boxes;
    Map<String, Uint8List> photoBytes = const {};

    if (file.name.toLowerCase().endsWith('.zip')) {
      final archive = ZipDecoder().decodeBytes(bytes);
      final manifest = archive.findFile('backup.json');
      if (manifest == null) {
        throw const BackupFormatException('Not a Treasure Box backup');
      }
      boxes = decodeBackupJson(utf8.decode(manifest.content));
      photoBytes = {
        for (final f in archive.files)
          if (f.isFile && f.name.startsWith('photos/'))
            f.name: Uint8List.fromList(f.content),
      };
    } else {
      boxes = decodeBackupJson(utf8.decode(bytes));
    }

    // Restore photos into app storage and point the drafts at them. When
    // there is nothing to restore (web, or a bare-JSON import), archive
    // photo refs are stripped so no dead path reaches the database.
    final restored = kIsWeb || photoBytes.isEmpty
        ? await _restorePhotos(boxes, const {})
        : await _restorePhotos(boxes, photoBytes);

    final written = await repo.importBackup(restored);
    return BackupOutcome(written == 0
        ? 'Everything in that backup is already here'
        : '$written items restored');
  } on BackupFormatException catch (e) {
    return BackupOutcome(e.message, failed: true);
  } catch (e) {
    if (kDebugMode) debugPrint('Import failed: $e');
    return const BackupOutcome('Could not read that file', failed: true);
  }
}

/// Writes packed photos to the app documents directory and rewrites each
/// draft's photoPath from its archive path to the restored local file.
/// With no [photoBytes] it only strips archive refs (no filesystem access).
Future<List<ImportedBox>> _restorePhotos(
  List<ImportedBox> boxes,
  Map<String, Uint8List> photoBytes,
) async {
  Directory? photoDir;
  if (photoBytes.isNotEmpty) {
    final dir = await getApplicationDocumentsDirectory();
    photoDir = Directory(p.join(dir.path, 'restored_photos'));
    await photoDir.create(recursive: true);
  }

  Future<ItemDraft> restore(ItemDraft draft) async {
    final archivePath = draft.photoPath;
    if (archivePath == null || !photoBytes.containsKey(archivePath)) {
      // No packed photo (bare-JSON import or missing entry): drop the ref.
      return ItemDraft(
        name: draft.name,
        category: draft.category,
        iconKey: draft.iconKey,
        qty: draft.qty,
        rarity: draft.rarity,
        notes: draft.notes,
        spot: draft.spot,
      );
    }
    final target = File(p.join(photoDir!.path, p.basename(archivePath)));
    await target.writeAsBytes(photoBytes[archivePath]!);
    return ItemDraft(
      name: draft.name,
      category: draft.category,
      iconKey: draft.iconKey,
      qty: draft.qty,
      rarity: draft.rarity,
      notes: draft.notes,
      spot: draft.spot,
      photoPath: target.path,
    );
  }

  return [
    for (final b in boxes)
      ImportedBox(
        name: b.name,
        slot: b.slot,
        capacity: b.capacity,
        skinKey: b.skinKey,
        items: [for (final d in b.items) await restore(d)],
      ),
  ];
}
