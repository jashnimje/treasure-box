import 'dart:async';

import 'nfc_service.dart';

/// Desktop/web/test implementation: no real hardware. [waitForTag] resolves
/// only when [simulateTap] fires (from the Settings "simulate a tap" action or
/// the home entry chip), so the room never auto-opens on its own.
class StubNfcService implements NfcService {
  final List<Completer<NfcTag>> _waiters = [];

  /// A tap fired while nobody was listening (e.g. from Settings before the
  /// home screen mounts) is buffered and consumed by the next [waitForTag].
  bool _pendingTap = false;

  static const _tag = NfcTag('SIMULATED-TAG', simulated: true);

  @override
  Future<bool> isAvailable() async => false;

  @override
  bool get supportsSimulation => true;

  @override
  void simulateTap() {
    if (_waiters.isEmpty) {
      _pendingTap = true;
      return;
    }
    final pending = List.of(_waiters);
    _waiters.clear();
    for (final waiter in pending) {
      if (!waiter.isCompleted) waiter.complete(_tag);
    }
  }

  @override
  Future<NfcTag> waitForTag() {
    if (_pendingTap) {
      _pendingTap = false;
      return Future.value(_tag);
    }
    final completer = Completer<NfcTag>();
    _waiters.add(completer);
    return completer.future;
  }

  @override
  Future<String> writeTag(String payload, {String? boxName}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return 'SIMULATED-TAG';
  }

  @override
  Future<void> stop() async {}
}

NfcService createNfcService() => StubNfcService();
