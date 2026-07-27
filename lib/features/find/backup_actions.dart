import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/data/backup/backup_codec.dart';
import '../../core/data/repositories/inventory_repository.dart';

/// Result of an export or import, for the snackbar.
class BackupOutcome {
  const BackupOutcome(this.message, {this.failed = false});

  final String message;
  final bool failed;
}

/// Export the whole inventory and hand it to the system share sheet -
/// on Android that includes "Save to Drive", so Google Drive backups work
/// with no cloud API. [asCsv] switches to the spreadsheet format.
Future<BackupOutcome> exportBackup(
  InventoryRepository repo, {
  required bool asCsv,
}) async {
  final backup = await repo.exportBackup();
  if (backup.boxes.isEmpty) {
    return const BackupOutcome('Nothing to export yet', failed: true);
  }
  final stamp = backup.exportedAt
      .toIso8601String()
      .substring(0, 19)
      .replaceAll(':', '-');
  final name = asCsv ? 'treasure-box-$stamp.csv' : 'treasure-box-$stamp.json';
  final content =
      asCsv ? encodeBackupCsv(backup) : encodeBackupJson(backup);

  final result = await SharePlus.instance.share(ShareParams(
    files: [
      XFile.fromData(
        utf8.encode(content),
        name: name,
        mimeType: asCsv ? 'text/csv' : 'application/json',
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
      '${backup.itemCount} items across ${backup.boxes.length} '
      '${backup.boxes.length == 1 ? 'chest' : 'chests'} exported');
}

/// Pick a JSON backup (the file picker browses Google Drive too) and merge
/// it in: boxes match by code, existing items are never duplicated.
Future<BackupOutcome> importBackup(InventoryRepository repo) async {
  final picked = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
    withData: true,
  );
  final file = picked?.files.firstOrNull;
  final bytes = file?.bytes;
  if (file == null || bytes == null) {
    return const BackupOutcome('Import cancelled', failed: true);
  }
  try {
    final boxes = decodeBackupJson(utf8.decode(bytes));
    final written = await repo.importBackup(boxes);
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
