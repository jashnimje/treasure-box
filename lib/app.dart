import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/data/models/box.dart';
import 'core/data/models/box_code.dart';
import 'core/platform/nfc_service.dart';
import 'core/platform/nfc_service_factory.dart';
import 'core/providers/box_providers.dart';
import 'core/providers/repository_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/minecraft_theme.dart';

class TreasureBoxApp extends ConsumerStatefulWidget {
  const TreasureBoxApp({super.key});

  @override
  ConsumerState<TreasureBoxApp> createState() => _TreasureBoxAppState();
}

class _TreasureBoxAppState extends ConsumerState<TreasureBoxApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _nfcLoop();
  }

  /// APP-LEVEL NFC listening: whatever screen is open, a tag tap resolves
  /// its box, returns to the room and plays the chest-open animation - the
  /// same path a cold-start deep link takes. (When this lived in the home
  /// screen, taps made anywhere else in the app were silently swallowed.)
  bool _nfcLoopRunning = false;

  Future<void> _nfcLoop() async {
    if (_nfcLoopRunning) return;
    _nfcLoopRunning = true;
    try {
      await _nfcLoopBody();
    } finally {
      _nfcLoopRunning = false;
    }
  }

  Future<void> _nfcLoopBody() async {
    final service = ref.read(nfcServiceProvider);
    var failures = 0;
    while (mounted) {
      final NfcTag tag;
      try {
        tag = await service.waitForTag();
        failures = 0;
      } on NfcUnavailable {
        // Transient error or a session reset on app resume: retry with a
        // fresh session. Give up only after repeated back-to-back failures
        // with NFC genuinely unavailable; resume revives the loop.
        failures++;
        if (failures >= 5 || !await service.isAvailable()) return;
        await Future<void>.delayed(const Duration(milliseconds: 600));
        continue;
      }
      if (!mounted) return;

      final repo = ref.read(inventoryRepositoryProvider);
      Box? target;
      if (!tag.simulated) {
        // Prefer the NDEF payload (the BOX-N code any phone can resolve),
        // then the linked hardware id, then adopt the tag for the default.
        if (tag.payload != null) {
          target = await repo.boxByAnyCode(tag.payload!);
        }
        target ??= await repo.boxByToken(tag.id);
        if (target == null) {
          target = await repo.currentBox();
          await repo.setNfcTag(target.id, tag.id);
        }
        await repo.markOpenedVia(target.id, BoxCodeSource.nfc);
      } else {
        target = await repo.currentBox();
      }
      if (!mounted) return;

      // Land in the room FIRST, then request the open: if home was buried
      // under pushed routes it may be recreated by the navigation, and the
      // request must be consumed by the instance that survives - requesting
      // first let a dying instance eat it (tap did nothing sometimes).
      ref.read(activeBoxIdProvider.notifier).select(target.id);
      ref.read(routerProvider).go('/');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      ref.read(pendingOpenProvider.notifier).request(target.id);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // On resume: re-assert fullscreen (the system restores its bars on app
  // switches/keyboards) and RESET the NFC session - Android tears reader
  // sessions down in the background, leaving a wait that never fires. The
  // stop() aborts the stale wait; the loop restarts with a fresh session
  // (and is revived here if it had given up, e.g. NFC was toggled off).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      ref.read(nfcServiceProvider).stop();
      if (!_nfcLoopRunning) _nfcLoop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Treasure Box',
      debugShowCheckedModeBanner: false,
      theme: buildMinecraftTheme(),
      routerConfig: router,
    );
  }
}
