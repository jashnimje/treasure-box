import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nfc_service.dart';
// On web there is no dart:io / nfc_manager, so use the stub. On native
// platforms use the mobile implementation (which itself reports unavailable on
// desktop).
import 'nfc_service_stub.dart'
    if (dart.library.io) 'nfc_service_mobile.dart';

/// The NFC service for the current platform. Overridable in tests.
final nfcServiceProvider = Provider<NfcService>((ref) => createNfcService());

/// Whether real NFC is available on this device (async, cached).
final nfcAvailableProvider = FutureProvider<bool>((ref) {
  return ref.watch(nfcServiceProvider).isAvailable();
});
