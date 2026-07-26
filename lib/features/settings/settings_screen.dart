import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/data/models/box.dart';
import '../../core/data/models/box_code.dart';
import '../../core/platform/nfc_service.dart';
import '../../core/platform/nfc_service_factory.dart';
import '../../core/providers/box_providers.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/danger_confirm_dialog.dart';
import '../../core/widgets/pixel_button.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/widgets/pixel_panel.dart';
import '../../core/widgets/pixel_stepper.dart';
import '../../core/widgets/pixel_text_field.dart';
import '../create_box/widgets/skin_picker.dart';
import 'widgets/chest_info_cards.dart';

/// The Info tab: everything about this chest in one place - what's inside
/// (stats), the label kit (QR + NFC), name/capacity settings, recent
/// additions, and the danger zone.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _initialized = false;
  int _capacity = 27;
  String _relinkState = 'idle';
  String _skinKey = 'oak';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _hydrate(Box box) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = box.name;
    _capacity = box.capacity;
    _skinKey = box.skinKey;
  }

  Future<void> _save(Box box, int usedSlots) async {
    final repo = ref.read(inventoryRepositoryProvider);
    final name = _nameController.text.trim();
    // Clamp capacity so it can never drop below what is already stored.
    final capacity = _capacity < usedSlots ? usedSlots : _capacity;
    await repo.renameBox(box.id, name.isEmpty ? 'Treasure Box' : name);
    await repo.setCapacity(box.id, capacity);
    await repo.setSkin(box.id, _skinKey);
    if (mounted) {
      setState(() => _capacity = capacity);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: context.mc.grassGreen,
          content: Text('Settings saved',
              style: context.mcText.bodyReadable
                  .copyWith(color: context.mc.white)),
        ),
      );
    }
  }

  Future<void> _relink(Box box) async {
    setState(() => _relinkState = 'writing');
    try {
      // Write the box CODE to the tag (URI + JSON metadata records). The
      // code survives box deletion/re-creation (slot reuse), so the tag
      // never needs rewriting.
      final tagId = await ref
          .read(nfcServiceProvider)
          .writeTag(box.code, boxName: box.name);
      await ref.read(inventoryRepositoryProvider).setNfcTag(box.id, tagId);
      if (mounted) setState(() => _relinkState = 'done');
    } on NfcUnavailable {
      if (mounted) {
        setState(() => _relinkState = 'idle');
        _snack('NFC unavailable on this device');
      }
    }
  }

  Future<void> _clear(Box box) async {
    final confirmed = await DangerConfirmDialog.ask(
      context,
      title: 'Clear the chest?',
      message: 'This removes every item. It cannot be undone.',
      confirmLabel: 'Clear',
    );
    if (confirmed) {
      await ref.read(inventoryRepositoryProvider).clearBox(box.id);
      if (mounted) _snack('Chest cleared');
    }
  }

  Future<void> _deleteBox(Box box) async {
    final confirmed = await DangerConfirmDialog.ask(
      context,
      title: 'Delete ${box.name}?',
      message: 'The chest and everything inside it will be gone. '
          'Its code (${box.code}) will be reused by the next new chest. '
          'This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed) {
      await ref.read(inventoryRepositoryProvider).deleteBox(box.id);
      // The deleted box may be the active one - fall back to the default.
      ref.read(activeBoxIdProvider.notifier).clear();
      if (mounted) context.go('/');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.mc.stoneDark,
        content: Text(msg,
            style:
                context.mcText.bodyReadable.copyWith(color: context.mc.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    final box = ref.watch(boxStreamProvider).valueOrNull;
    final capacity = ref.watch(capacityProvider);
    final nfcAvailable = ref.watch(nfcAvailableProvider).valueOrNull ?? false;
    final canSimulate = ref.read(nfcServiceProvider).supportsSimulation;

    if (box == null) {
      return const Center(child: CircularProgressIndicator());
    }
    _hydrate(box);

    final items = ref.watch(itemsProvider).valueOrNull ?? const [];

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: mc.headerBar,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Text('${box.name} info',
              style: text.headingPixel, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: Container(
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
              // ---- Section 1: THE CHEST (contents + its settings) ----
              _SectionLabel('WHAT\'S INSIDE'),
              ChestStatsCard(capacity: capacity, items: items),
              const SizedBox(height: 20),
              _SectionLabel('RECENTLY ADDED'),
              RecentItemsCard(boxId: box.id, showBoxName: false),
              const SizedBox(height: 20),
              _SectionLabel('CHEST NAME'),
              PixelTextField(controller: _nameController),
              const SizedBox(height: 20),
              _SectionLabel('CHEST STYLE'),
              SkinPicker(
                selectedSkin: _skinKey,
                onSkinSelected: (key) => setState(() => _skinKey = key),
              ),
              const SizedBox(height: 20),
              _SectionLabel('MAX CAPACITY'),
              PixelStepper(
                value: _capacity,
                min: 9,
                max: 54,
                step: 9,
                suffix: 'SLOTS',
                onChanged: (v) => setState(() => _capacity = v),
              ),
              if (_capacity < capacity.used)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Will keep ${capacity.used} (items already stored)',
                    style: text.bodyReadable.copyWith(color: mc.gold),
                  ),
                ),
              const SizedBox(height: 16),
              PixelButton(
                variant: PixelButtonVariant.grass,
                width: double.infinity,
                height: 52,
                onPressed: () => _save(box, capacity.used),
                child: Text('Save settings',
                    style: text.labelPixel.copyWith(color: mc.white)),
              ),

              // ---- Section 2: LABELS & TAGS (QR + NFC in one place) ----
              const _SectionDivider('LABELS & TAGS'),
              _BoxIdentityCard(box: box),
              const SizedBox(height: 14),
              PixelPanel(
                fill: mc.headerBar,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PixelIcon('nfc',
                            size: 32,
                            tint: box.isLinked ? mc.xpGreen : mc.stoneMid),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                box.isLinked
                                    ? 'NFC TAG LINKED'
                                    : 'NO TAG LINKED',
                                style: text.labelPixel.copyWith(
                                    color: box.isLinked
                                        ? mc.xpGreen
                                        : mc.stoneMid),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                box.isLinked
                                    ? 'TAG: ${box.nfcTagId}'
                                    : 'Write a tag below to link this chest',
                                style: text.bodyReadable
                                    .copyWith(color: mc.stoneMid),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nfcAvailable
                          ? 'Tapping a linked tag opens its chest. An '
                              'unknown tag links itself to your default chest.'
                          : 'No NFC on this device - the app works fully '
                              'without it. Taps can be simulated below.',
                      style: text.bodyReadable.copyWith(color: mc.stoneMid),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PixelButton(
                variant: PixelButtonVariant.plank,
                width: double.infinity,
                onPressed: nfcAvailable && _relinkState != 'writing'
                    ? () => _relink(box)
                    : null,
                child: Text(
                  switch (_relinkState) {
                    'writing' => 'WRITING TAG...',
                    'done' => 'TAG WRITTEN!',
                    _ => 'Write tag',
                  },
                  style: text.labelPixel.copyWith(color: mc.obsidian),
                ),
              ),
              if (canSimulate) ...[
                const SizedBox(height: 12),
                PixelButton(
                  variant: PixelButtonVariant.diamond,
                  width: double.infinity,
                  onPressed: () {
                    ref.read(nfcServiceProvider).simulateTap();
                    context.go('/');
                  },
                  child: Text(
                    'Simulate a tap',
                    style: text.labelPixel.copyWith(color: mc.obsidian),
                  ),
                ),
              ],

              // ---- Section 3: DANGER ZONE (bottom-most, hard to fat-finger) ----
              const _SectionDivider('DANGER ZONE', danger: true),
              PixelButton(
                variant: PixelButtonVariant.redstone,
                width: double.infinity,
                onPressed: () => _clear(box),
                child: Text('Clear the chest',
                    style: text.labelPixel.copyWith(color: mc.white)),
              ),
              const SizedBox(height: 12),
              PixelButton(
                variant: PixelButtonVariant.redstone,
                width: double.infinity,
                onPressed: () => _deleteBox(box),
                child: Text('Delete this chest',
                    style: text.labelPixel.copyWith(color: mc.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
          ),
        ),
      ],
    );
  }
}

/// The box's identity: ONE human code (`BOX-N`) carried by every rail. The
/// QR encodes the code itself; the NFC write puts the same code on the tag;
/// a marker label works too. Slots are reused after deletion, so printed
/// labels and written tags never go stale.
class _BoxIdentityCard extends StatelessWidget {
  const _BoxIdentityCard({required this.box});

  final Box box;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    final code = box.code;

    return PixelPanel(
      fill: mc.headerBar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // QR on a white pixel-card so any scanner reads it.
              Container(
                padding: const EdgeInsets.all(6),
                color: Colors.white,
                // The QR carries treasurebox://box/TB:BOX-N:QR - the scheme
                // makes a camera scan OPEN the app, the envelope tells the
                // app the scan came from the QR rail, not a typed code.
                child: QrImageView(
                  data: qrDeepLink(code),
                  version: QrVersions.auto,
                  size: 104,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(code,
                        style: text.headingPixel.copyWith(color: mc.gold)),
                    const SizedBox(height: 8),
                    Text(
                      'This one code is the box. Print the QR, write it '
                      'to an NFC tag below, or just write it on with a '
                      'marker - scan or type it and the chest opens.',
                      style: text.bodyReadable
                          .copyWith(color: mc.stoneMid, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PixelButton(
            width: double.infinity,
            height: 40,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: context.mc.grassGreen,
                    content: Text('Code copied',
                        style: context.mcText.bodyReadable
                            .copyWith(color: context.mc.white)),
                  ),
                );
              }
            },
            child: Text('Copy code',
                style: text.labelPixel.copyWith(color: mc.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: context.mcText.labelPixel.copyWith(color: context.mc.stoneMid),
      ),
    );
  }
}

/// A heavy visual break between major Info sections: bedrock-style rule
/// lines flanking the section title, with generous breathing room.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider(this.title, {this.danger = false});
  final String title;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final color = danger ? mc.redstone : mc.stoneMid;
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: Container(
                  height: 3, color: mc.obsidianLight.withValues(alpha: 0.8))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(title,
                style: context.mcText.labelPixel.copyWith(color: color)),
          ),
          Expanded(
              child: Container(
                  height: 3, color: mc.obsidianLight.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

