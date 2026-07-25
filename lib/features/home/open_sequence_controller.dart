import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Phases of the chest-open sequence.
enum OpenSequencePhase { idle, lid, dwell }

/// Orchestrates the chest-open moment the Minecraft way: the world never
/// warps. The lid swings open on the chest itself ([lidOpenValue]) while the
/// camera pushes in slightly ([pushScale]). After a short dwell at full
/// open, [onComplete] fires and the inventory chunk-loads over the room via
/// the route's block-wipe transition.
class OpenSequenceController extends ChangeNotifier {
  OpenSequenceController({
    required TickerProvider vsync,
    this.onComplete,
  }) {
    _lid = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 550),
    );
    _dwell = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
    _lid.addListener(notifyListeners);
    _dwell.addListener(notifyListeners);
  }

  late final AnimationController _lid;
  late final AnimationController _dwell;

  OpenSequencePhase _phase = OpenSequencePhase.idle;

  /// Callback invoked when the dwell completes (triggers navigation).
  VoidCallback? onComplete;

  /// The current animation phase.
  OpenSequencePhase get phase => _phase;

  /// Whether the sequence is in progress (not idle).
  bool get isActive => _phase != OpenSequencePhase.idle;

  // --- Derived animation values ---

  /// Lid open amount: 0.0 (closed) -> 1.0 (fully open).
  double get lidOpenValue => Curves.easeOutCubic.transform(_lid.value);

  /// Subtle camera push-in: 1.0 -> 1.06 across the whole sequence. The room
  /// scales gently toward the chest - depth without distortion.
  double get pushScale =>
      1.0 +
      0.06 * Curves.easeInOut.transform((_lid.value + _dwell.value) / 2);

  /// Spark/glow driver, 0..1 across lid + dwell. Sparks rise from the chest
  /// as it opens and keep going while the treasure glow holds.

  /// Starts the sequence: lid swings open, dwell at full open, then complete.
  ///
  /// If already active, this is a no-op.
  void start() {
    if (isActive) return;

    _phase = OpenSequencePhase.lid;
    notifyListeners();

    _lid.forward().then((_) {
      if (_phase != OpenSequencePhase.lid) return;
      _phase = OpenSequencePhase.dwell;
      notifyListeners();
      _dwell.forward().then((_) {
        if (_phase != OpenSequencePhase.dwell) return;
        onComplete?.call();
      });
    });
  }

  /// Cancels and reverses any in-progress animation, resets phase to idle.
  void cancel() {
    _phase = OpenSequencePhase.idle;
    notifyListeners();

    for (final controller in [_dwell, _lid]) {
      if (controller.isAnimating || controller.value > 0) {
        controller.reverse();
      }
    }
  }

  /// Resets all controllers to their initial state without animation.
  void reset() {
    _phase = OpenSequencePhase.idle;
    _lid.reset();
    _dwell.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _lid.dispose();
    _dwell.dispose();
    super.dispose();
  }
}
