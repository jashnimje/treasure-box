import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/pixel_button.dart';
import '../../core/widgets/pixel_panel.dart';
import 'backup_actions.dart' as backup;

/// Global app settings: backup and restore, and the About book. Per-chest
/// settings (name, style, capacity, tags) live in that chest's Info tab.
class GlobalSettingsScreen extends ConsumerStatefulWidget {
  const GlobalSettingsScreen({super.key});

  @override
  ConsumerState<GlobalSettingsScreen> createState() =>
      _GlobalSettingsScreenState();
}

class _GlobalSettingsScreenState extends ConsumerState<GlobalSettingsScreen> {
  bool _busy = false;

  Future<void> _run(Future<backup.BackupOutcome> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final outcome = await action();
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

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;

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
            Text('BACKUP',
                style: text.labelPixel.copyWith(color: mc.stoneMid)),
            const SizedBox(height: 10),
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: PixelButton(
                          height: 46,
                          onPressed: _busy
                              ? null
                              : () => _run(() => backup.exportBackup(ref
                                  .read(inventoryRepositoryProvider))),
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
            Text('ABOUT',
                style: text.labelPixel.copyWith(color: mc.stoneMid)),
            const SizedBox(height: 10),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
