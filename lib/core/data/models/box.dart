/// A treasure box. Multiple boxes are supported; each is placed in the room and
/// carries a stable [qrToken] for deep links / QR / NFC and a [skinKey]
/// cosmetic.
class Box {
  const Box({
    required this.id,
    required this.name,
    required this.capacity,
    required this.skinKey,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.slot = 0,
    this.nfcTagId,
    this.qrToken,
    this.qrUsedAt,
    this.nfcUsedAt,
  });

  final int id;
  final String name;

  /// Maximum number of item stacks/slots (not summed quantity).
  final int capacity;
  final String? nfcTagId;
  final String? qrToken;

  /// Identity slot (1-based). `BOX-<slot>` is the code on the label.
  final int slot;
  final String skinKey;

  final int sortOrder;

  /// Last time this box was opened via a scanned QR (null = never).
  final DateTime? qrUsedAt;

  /// Last time this box was opened via an NFC tap (null = never).
  final DateTime? nfcUsedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLinked => nfcTagId != null && nfcTagId!.isNotEmpty;

  /// Rails this box has actually earned: NFC when a tag is linked or was
  /// ever tapped, QR once a scan opened it. The typed code always works.
  bool get hasNfcRail => isLinked || nfcUsedAt != null;
  bool get hasQrRail => qrUsedAt != null;

  /// The human identity code carried by every rail (QR, NFC payload, typed).
  String get code => qrToken ?? 'BOX-$slot';

  /// Deep link that opens this box (`/box/BOX-<slot>`).
  String get deepLink => '/box/$code';
}