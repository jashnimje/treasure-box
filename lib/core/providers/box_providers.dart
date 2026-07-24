import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/box.dart';
import '../data/models/item.dart';
import 'repository_providers.dart';

/// All boxes in the room, reactive and display-ordered.
final boxesProvider = StreamProvider<List<Box>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchBoxes();
});

/// Which box the user is currently viewing. `null` means "the default box"
/// (resolved lazily so the app works before any box is explicitly opened).
class ActiveBoxIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int boxId) => state = boxId;
  void clear() => state = null;
}

final activeBoxIdProvider =
    NotifierProvider<ActiveBoxIdNotifier, int?>(ActiveBoxIdNotifier.new);

/// A box waiting to be opened WITH the cinematic lid animation - set by the
/// deep-link resolver (NFC tap / QR scan), consumed once by the home screen.
class PendingOpenNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void request(int boxId) => state = boxId;

  /// Take and clear the pending request.
  int? consume() {
    final id = state;
    state = null;
    return id;
  }
}

final pendingOpenProvider =
    NotifierProvider<PendingOpenNotifier, int?>(PendingOpenNotifier.new);

/// The active box: the explicitly selected one, or the default box.
final activeBoxProvider = FutureProvider<Box>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  final id = ref.watch(activeBoxIdProvider);
  if (id == null) return repo.currentBox();
  // Resolve from the live list so it stays valid after edits/deletes.
  final boxes = await ref.watch(boxesProvider.future);
  return boxes.firstWhere((b) => b.id == id, orElse: () => boxes.first);
});

/// Reactive stream of the active box's items.
final itemsProvider = StreamProvider<List<Item>>((ref) async* {
  final repo = ref.watch(inventoryRepositoryProvider);
  final box = await ref.watch(activeBoxProvider.future);
  yield* repo.watchItems(box.id);
});

/// Live box row (name/capacity/nfc) for the active box.
final boxStreamProvider = StreamProvider<Box>((ref) async* {
  final repo = ref.watch(inventoryRepositoryProvider);
  final box = await ref.watch(activeBoxProvider.future);
  yield* repo.watchBox(box.id);
});

/// Derived capacity information for the active box.
class CapacityInfo {
  const CapacityInfo({required this.used, required this.capacity});

  final int used;
  final int capacity;

  double get fraction => capacity == 0 ? 0 : (used / capacity).clamp(0, 1);
  bool get isFull => used >= capacity;
  bool get isNearFull => fraction > 0.8;
  int get remaining => (capacity - used).clamp(0, capacity);
}

final capacityProvider = Provider<CapacityInfo>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const [];
  final box = ref.watch(boxStreamProvider).valueOrNull;
  return CapacityInfo(
    used: items.length,
    capacity: box?.capacity ?? 27,
  );
});
