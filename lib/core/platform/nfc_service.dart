/// Abstraction over NFC so the rest of the app never imports `nfc_manager`
/// directly. The mobile implementation talks to real hardware; a stub is used
/// on desktop/web (and in tests), where taps can only be simulated.
abstract class NfcService {
  /// Whether real NFC hardware is available on this device.
  Future<bool> isAvailable();

  /// Wait for a tag to be presented. If the tag's NDEF payload carries a box
  /// code (written by [writeTag]), [NfcTag.payload] holds it; [NfcTag.id] is
  /// the hardware id. On the stub this resolves only when [simulateTap] is
  /// called - the app never auto-opens a chest without a real (or explicitly
  /// simulated) tap.
  Future<NfcTag> waitForTag();

  /// Write [payload] (the box code, e.g. `BOX-1`) to the next presented tag.
  /// On real hardware two NDEF records are written: a `treasurebox://box/...`
  /// URI (auto-opens the app) and a JSON text record with the code and
  /// optional [boxName] (NTAG216 has 888 bytes - room to spare). Returns the
  /// tag's hardware id.
  Future<String> writeTag(String payload, {String? boxName});

  /// Stop any in-flight session (safe to call when idle).
  Future<void> stop();

  /// True when this implementation can fake a tag (desktop/web stub).
  bool get supportsSimulation;

  /// Deliver a simulated tag to any [waitForTag] waiter. No-op on real NFC.
  void simulateTap();
}

/// A detected tag.
class NfcTag {
  const NfcTag(this.id, {this.payload, this.simulated = false});

  /// Hardware id of the tag.
  final String id;

  /// The box code read from the tag's NDEF record, if it carries one.
  final String? payload;

  /// True when produced by the stub rather than real hardware.
  final bool simulated;
}

/// Raised when NFC is unavailable or a session cannot start.
class NfcUnavailable implements Exception {
  const NfcUnavailable([this.message = 'NFC is not available']);
  final String message;

  @override
  String toString() => 'NfcUnavailable: $message';
}
