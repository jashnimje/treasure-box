import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/widgets/performance_throttle.dart';

void main() {
  group('PerformanceThrottle', () {
    test('initializes currentMax to defaultMax', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      expect(throttle.currentMax, 120);
      expect(throttle.isThrottled, false);
    });

    test('floor is 20% of defaultMax', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      expect(throttle.floor, 24);
    });

    test('does not throttle until 30 frames are recorded', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      // Record 29 frames at 20ms each (above threshold)
      for (var i = 0; i < 29; i++) {
        throttle.recordFrame(0.020); // 20ms
      }
      expect(throttle.currentMax, 120);
      expect(throttle.isThrottled, false);
    });

    test('throttles when average exceeds 18ms', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      // Record 30 frames at 20ms each (average = 20ms > 18ms)
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.020);
      }
      expect(throttle.isThrottled, true);
      // currentMax = max(120 * 0.5, 120 * 0.2) = max(60, 24) = 60
      expect(throttle.currentMax, 60);
    });

    test('does not throttle when average is exactly 18ms', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.018); // exactly 18ms
      }
      expect(throttle.isThrottled, false);
      expect(throttle.currentMax, 120);
    });

    test('restores when average drops below 12ms after throttle', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      // First, trigger throttle
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.020);
      }
      expect(throttle.isThrottled, true);
      expect(throttle.currentMax, 60);

      // Now record 30 fast frames (10ms each, average = 10ms < 12ms)
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.010);
      }
      expect(throttle.isThrottled, false);
      expect(throttle.currentMax, 120);
    });

    test('does not restore when average is exactly 12ms', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      // Trigger throttle
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.020);
      }
      expect(throttle.isThrottled, true);

      // Record at exactly 12ms (should NOT restore)
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.012);
      }
      expect(throttle.isThrottled, true);
      expect(throttle.currentMax, 60);
    });

    test('currentMax never drops below floor', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      // Trigger throttle: currentMax = 60
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.020);
      }
      expect(throttle.currentMax, 60);

      // Restore
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.010);
      }
      expect(throttle.currentMax, 120);

      // Throttle again from 120: currentMax = 60
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.020);
      }
      expect(throttle.currentMax, 60);

      // The floor is 24 (120 * 0.2). Since throttle only fires once
      // (isThrottled prevents re-fire), currentMax stays at 60 which is > floor.
      expect(throttle.currentMax >= throttle.floor, true);
    });

    test('hysteresis prevents oscillation between 12ms and 18ms', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      // Trigger throttle
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.020);
      }
      expect(throttle.isThrottled, true);

      // Frames at 15ms (between 12 and 18): should NOT restore
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.015);
      }
      expect(throttle.isThrottled, true);
      expect(throttle.currentMax, 60);
    });

    test('does not double-throttle while already throttled', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      // Trigger throttle: currentMax = 60
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.020);
      }
      expect(throttle.currentMax, 60);

      // More high frames should NOT reduce further
      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.025);
      }
      expect(throttle.currentMax, 60);
    });

    test('rolling window only keeps last 30 frames', () {
      final throttle = PerformanceThrottle(defaultMax: 120);
      // Record 25 fast frames (8ms)
      for (var i = 0; i < 25; i++) {
        throttle.recordFrame(0.008);
      }
      // Record 5 slow frames (50ms) to bring total to 30
      // Average = (25*8 + 5*50) / 30 = (200 + 250) / 30 = 15ms
      for (var i = 0; i < 5; i++) {
        throttle.recordFrame(0.050);
      }
      expect(throttle.isThrottled, false); // 15ms < 18ms

      // Now push out old fast frames by adding more slow frames
      // After 25 more slow frames, window = 5 old slow + 25 new slow = all 50ms
      for (var i = 0; i < 25; i++) {
        throttle.recordFrame(0.050);
      }
      expect(throttle.isThrottled, true); // average = 50ms > 18ms
    });

    test('works with small defaultMax values', () {
      final throttle = PerformanceThrottle(defaultMax: 10);
      expect(throttle.floor, 2); // 10 * 0.2 = 2

      for (var i = 0; i < 30; i++) {
        throttle.recordFrame(0.020);
      }
      // currentMax = max(10 * 0.5, 10 * 0.2) = max(5, 2) = 5
      expect(throttle.currentMax, 5);
      expect(throttle.currentMax >= throttle.floor, true);
    });
  });
}
