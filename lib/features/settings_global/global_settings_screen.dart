import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/box_providers.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/danger_confirm_dialog.dart';
import '../../core/widgets/pixel_button.dart';
import '../../core/widgets/pixel_panel.dart';
import 'backup_actions.dart' as backup;

/// App version shown in About. Keep in step with pubspec.yaml.
const String kAppVersion = '1.0.0';

/// Global app settings: backup and restore, a short guide to the open
/// rails, the About book, and the global danger zone. Per-chest settings
/// (name, style, capacity, tags) live in that chest's Info tab.
class GlobalSettingsScreen extends ConsumerStatefulWidget {
  const GlobalSettingsScreen({super.key});

  @override
  ConsumerState<GlobalSettingsScreen> createState() =>
      _GlobalSettingsScreenState();
}

class _GlobalSettingsScreenState extends ConsumerState<GlobalSettingsScreen> {
  bool _busy = false;

  Future<void> _run(Future<backup.BackupOutcome> Function() action,
      {bool stampOnSuccess = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final outcome = await action();
      if (!outcome.failed && stampOnSuccess) {
        await ref.read(backup.lastBackupProvider.notifier).stamp();
      }
      if (!mounted) return;
      final mc = context.mc;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: outcome.failed ? mc.stoneDark : mc.grassGreen,
        content: Text(outcome.message,
            style: context.mcText.bodyReadable.copyWith(color: mc.white)),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startFresh() async {
    final confirmed = await DangerConfirmDialog.ask(
      context,
      title: 'Start fresh?',
      message: 'Every chest and every item will be deleted. Export a '
          'backup first if you might want any of it back. This cannot '
          'be undone.',
      confirmLabel: 'Delete all',
    );
    if (!confirmed) return;
    final repo = ref.read(inventoryRepositoryProvider);
    final boxes = await ref.read(boxesProvider.future);
    for (final box in boxes) {
      await repo.deleteBox(box.id);
    }
    ref.read(activeBoxIdProvider.notifier).clear();
    if (mounted) context.go('/');
  }

  String _ago(DateTime when) {
    final d = DateTime.now().difference(when);
    if (d.inDays >= 7) return '${d.inDays ~/ 7} weeks ago';
    if (d.inDays >= 1) return '${d.inDays} days ago';
    if (d.inHours >= 1) return '${d.inHours} hours ago';
    if (d.inMinutes >= 1) return '${d.inMinutes} minutes ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    final lastBackup = ref.watch(backup.lastBackupProvider);

    return Scaffold(
      backgroundColor: mc.voidDark,
      appBar: AppBar(
        backgroundColor: mc.headerBar,
        foregroundColor: mc.white,
        title: Text('Settings', style: text.headingPixel),
        shape: Border(bottom: BorderSide(color: mc.obsidianLight, width: 3)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mc.obsidian, mc.obsidianDeep],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Backup ----
            _SectionLabel('BACKUP'),
            PixelPanel(
              fill: mc.headerBar,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'One file holds everything: every chest, every item, '
                    'and the photos. Share it to Google Drive, email, or '
                    'anywhere else. Import merges a backup back in without '
                    'duplicating what you already have.',
                    style: text.bodyReadable
                        .copyWith(color: mc.stoneMid, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.history,
                          size: 15,
                          color: lastBackup == null
                              ? mc.gold
                              : mc.stoneMid),
                      const SizedBox(width: 6),
                      Text(
                        lastBackup == null
                            ? 'No backup yet - export one to be safe'
                            : 'Last backup ${_ago(lastBackup)}',
                        style: text.bodyReadable.copyWith(
                            color: lastBackup == null
                                ? mc.gold
                                : mc.stoneMid,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: PixelButton(
                          height: 46,
                          onPressed: _busy
                              ? null
                              : () => _run(
                                    () => backup.exportBackup(ref.read(
                                        inventoryRepositoryProvider)),
                                    stampOnSuccess: true,
                                  ),
                          child: Text('Export backup',
                              style: text.labelPixel
                                  .copyWith(color: mc.white, fontSize: 10)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PixelButton(
                          height: 46,
                          variant: PixelButtonVariant.grass,
                          onPressed: _busy
                              ? null
                              : () => _run(() => backup.importBackup(ref
                                  .read(inventoryRepositoryProvider))),
                          child: Text('Import',
                              style: text.labelPixel
                                  .copyWith(color: mc.white, fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- How opening works (for whoever holds the box) ----
            _SectionLabel('HOW TO OPEN A CHEST'),
            PixelPanel(
              fill: mc.headerBar,
              child: Column(
                children: const [
                  _GuideRow(Icons.sensors,
                      'Tap the phone on the chest\'s NFC tag'),
                  _GuideRow(Icons.qr_code_scanner,
                      'Scan the printed QR label from home'),
                  _GuideRow(Icons.keyboard,
                      'Or just type the code, like BOX-1'),
                  _GuideRow(Icons.touch_app,
                      'In the room, tapping a chest always works'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- About ----
            _SectionLabel('ABOUT'),
            PixelPanel(
              fill: mc.headerBar,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Book of the Chest - the story behind this app, '
                    'yours to rewrite.',
                    style: text.bodyReadable
                        .copyWith(color: mc.stoneMid, fontSize: 15),
                  ),
                  const SizedBox(height: 14),
                  PixelButton(
                    width: double.infinity,
                    height: 46,
                    onPressed: () => context.push('/about'),
                    child: Text('Open the book',
                        style: text.labelPixel
                            .copyWith(color: mc.white, fontSize: 10)),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Treasure Box $kAppVersion',
                      style: text.bodyReadable
                          .copyWith(color: mc.stoneDark, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ---- Danger zone ----
            _SectionLabel('DANGER ZONE', danger: true),
            PixelButton(
              variant: PixelButtonVariant.redstone,
              width: double.infinity,
              onPressed: _startFresh,
              child: Text('Start fresh',
                  style: text.labelPixel.copyWith(color: mc.white)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {this.danger = false});

  final String title;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: context.mcText.labelPixel
            .copyWith(color: danger ? mc.redstone : mc.stoneMid),
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow(this.icon, this.line);

  final IconData icon;
  final String line;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: mc.diamond),
          const SizedBox(width: 12),
          Expanded(
            child: Text(line,
                style: text.bodyReadable
                    .copyWith(color: mc.stoneLight, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
