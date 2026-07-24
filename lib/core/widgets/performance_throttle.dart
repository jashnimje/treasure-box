import 'dart:collection';
import 'dart:math';

/// Monitors frame durations and throttles particle count to maintain performance.
///
/// Tracks a rolling window of the last 30 frame durations (in milliseconds).
/// When the average exceeds 18ms, reduces [currentMax] by half (floored at
/// [defaultMax] * 0.2). When the average drops below 12ms after throttling,
/// restores [currentMax] to [defaultMax].
///
/// Invariant: [currentMax] >= [floor] always holds.
class PerformanceThrottle {
  PerformanceThrottle({required this.defaultMax})
      : _currentMax = defaultMax;

  /// The default (unthrottled) maximum particle count.
  final int defaultMax;

  /// Rolling window of the last 30 frame durations in milliseconds.
  final Queue<double> _frameTimes = Queue<double>();

  int _currentMax;
  bool _isThrottled = false;

  /// The current maximum particle count, adjusted by throttle logic.
  int get currentMax => _currentMax;

  /// Whether the throttle is currently active (particle count reduced).
  bool get isThrottled => _isThrottled;

  /// The minimum particle count floor: [defaultMax] * 0.2, rounded.
  int get floor => (defaultMax * 0.2).round();

  /// Records a frame duration and adjusts [currentMax] if needed.
  ///
  /// [dtSeconds] is the frame delta time in seconds. It is converted to
  /// milliseconds internally for averaging.
  void recordFrame(double dtSeconds) {
    _frameTimes.addLast(dtSeconds * 1000);
    if (_frameTimes.length > 30) _frameTimes.removeFirst();
    if (_frameTimes.length < 30) return;

    final avg = _frameTimes.reduce((a, b) => a + b) / 30;

    if (avg > 18 && !_isThrottled) {
      _currentMax = max((_currentMax * 0.5).round(), floor);
      _isThrottled = true;
    } else if (avg < 12 && _isThrottled) {
      _currentMax = defaultMax;
      _isThrottled = false;
    }
  }
}
