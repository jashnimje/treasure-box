import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/features/home/room_camera_controller.dart';

void main() {
  group('RoomCameraController', () {
    group('bounds computation', () {
      test('computes minOffset and maxOffset from chest positions', () {
        final controller = RoomCameraController(
          chestPositions: [200, 400, 600],
          viewportWidth: 400,
        );
        // minOffset centers the first chest: 200 - 400/2 = 0. This keeps the
        // initial offset (0) in-bounds so the camera never jumps on rebuild.
        expect(controller.minOffset, 0.0);
        // maxOffset centers the last slot: 600 - 400/2 = 400.
        expect(controller.maxOffset, 400.0);
      });

      test('returns 0 bounds when chestPositions is empty', () {
        final controller = RoomCameraController(
          chestPositions: [],
          viewportWidth: 400,
        );
        expect(controller.minOffset, 0.0);
        expect(controller.maxOffset, 0.0);
        expect(controller.offset, 0.0);
      });
    });

    group('pan', () {
      test('updates offset by subtracting dx', () {
        final controller = RoomCameraController(
          chestPositions: [0, 200, 400],
          viewportWidth: 400,
        );
        controller.pan(-50); // offset = 0 - (-50) = 50
        expect(controller.offset, 50.0);
      });

      test('clamps offset within bounds', () {
        final controller = RoomCameraController(
          chestPositions: [0, 200, 400],
          viewportWidth: 400,
        );
        // Try panning far to the right (large negative dx -> large positive offset)
        controller.pan(-9999);
        expect(controller.offset, controller.maxOffset);

        // Try panning far to the left
        controller.pan(99999);
        expect(controller.offset, controller.minOffset);
      });

      test('does nothing when chestPositions is empty', () {
        final controller = RoomCameraController(
          chestPositions: [],
          viewportWidth: 400,
        );
        controller.pan(-100);
        expect(controller.offset, 0.0);
      });

      test('notifies listeners on pan', () {
        final controller = RoomCameraController(
          chestPositions: [0, 200, 400],
          viewportWidth: 400,
        );
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);
        controller.pan(-10);
        expect(notifyCount, 1);
      });
    });

    group('focusedIndex', () {
      test('returns index of chest nearest to viewport center', () {
        final controller = RoomCameraController(
          chestPositions: [0, 200, 400],
          viewportWidth: 400,
        );
        // offset = 0, center = 0 + 400/2 = 200 -> nearest is index 1 (at 200)
        expect(controller.focusedIndex, 1);
      });

      test('returns -1 when no chest within threshold', () {
        final controller = RoomCameraController(
          chestPositions: [0, 1000],
          viewportWidth: 100,
        );
        // offset = 0, center = 50, nearest is 0 (distance 50), threshold = 0.4 * 100 = 40
        // 50 > 40, so no focused chest
        expect(controller.focusedIndex, -1);
      });

      test('returns -1 when chestPositions is empty', () {
        final controller = RoomCameraController(
          chestPositions: [],
          viewportWidth: 400,
        );
        expect(controller.focusedIndex, -1);
      });

      test('correctly identifies focus after panning', () {
        final controller = RoomCameraController(
          chestPositions: [0, 200, 400],
          viewportWidth: 400,
        );
        // Pan so that center aligns with chest at 400
        // Need offset such that offset + 200 = 400 -> offset = 200
        controller.pan(-120); // offset goes to 120 (clamped to maxOffset)
        // center = 120 + 200 = 320, nearest is 400 (distance 80 < 160 threshold)
        expect(controller.focusedIndex, 2);
      });
    });

    group('updatePositions', () {
      test('updates positions and re-clamps offset', () {
        final controller = RoomCameraController(
          chestPositions: [0, 200, 400],
          viewportWidth: 400,
        );
        controller.pan(-120); // offset = 120 (maxOffset)

        // Now update positions to a wider range
        controller.updatePositions([0, 200, 400, 600]);
        // New maxOffset = 600 + 120 - 400 = 320
        // New minOffset = 0 - 120 = -120
        // offset 120 is within [-120, 320], stays at 120
        expect(controller.offset, 120.0);
      });

      test('re-clamps offset when the content range shrinks', () {
        final controller = RoomCameraController(
          chestPositions: [0, 200, 400],
          viewportWidth: 400,
        );
        controller.pan(-120); // offset = 120

        // Shrink the content range; bounds center first/last chests:
        // minOffset = 0 - 200 = -200, maxOffset = 100 - 200 = -100.
        controller.updatePositions([0, 100]);
        expect(controller.offset, -100.0);
      });

      test('resets offset to 0 when positions become empty', () {
        final controller = RoomCameraController(
          chestPositions: [0, 200],
          viewportWidth: 400,
        );
        controller.pan(-50);
        controller.updatePositions([]);
        expect(controller.offset, 0.0);
      });

      test('notifies listeners when positions update', () {
        final controller = RoomCameraController(
          chestPositions: [0, 200],
          viewportWidth: 400,
        );
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);
        controller.updatePositions([0, 200, 400]);
        expect(notifyCount, 1);
      });
    });

    group('snapToNearest', () {
      testWidgets('animates offset toward nearest chest center',
          (tester) async {
        final controller = RoomCameraController(
          chestPositions: [0, 200, 400],
          viewportWidth: 400,
        );
        // Pan slightly off-center from chest at 200
        // offset = 30, center = 30 + 200 = 230, nearest chest = 200
        // target offset = 200 - 200 = 0
        controller.pan(-30);
        expect(controller.offset, 30.0);

        await tester.pumpWidget(
          _TickerProviderWidget(
            onBuild: (vsync) {
              controller.snapToNearest(vsync);
            },
          ),
        );

        // Pump through the animation
        await tester.pumpAndSettle();

        // Should have snapped to offset that centers on chest 200
        // target = 200 - 200 = 0
        expect(controller.offset, closeTo(0.0, 0.5));
      });

      testWidgets('is cancellable by pan during animation', (tester) async {
        final controller = RoomCameraController(
          chestPositions: [0, 200, 400],
          viewportWidth: 400,
        );
        controller.pan(-100); // offset = 100

        await tester.pumpWidget(
          _TickerProviderWidget(
            onBuild: (vsync) {
              controller.snapToNearest(vsync);
            },
          ),
        );

        // Pump a few frames but don't settle
        await tester.pump(const Duration(milliseconds: 100));

        // Pan mid-snap should cancel the animation
        controller.pan(-10);

        // The offset should reflect the pan, not continue animating
        final offsetAfterPan = controller.offset;
        await tester.pump(const Duration(milliseconds: 300));
        // Offset should not have changed from the pan (no more animation)
        expect(controller.offset, offsetAfterPan);
      });
    });

    group('dispose', () {
      testWidgets('disposes active snap animation controller', (tester) async {
        final controller = RoomCameraController(
          chestPositions: [0, 200, 400],
          viewportWidth: 400,
        );
        controller.pan(-50);

        await tester.pumpWidget(
          _TickerProviderWidget(
            onBuild: (vsync) {
              controller.snapToNearest(vsync);
            },
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        // Dispose should not throw
        controller.dispose();
      });
    });
  });
}

/// Helper widget that provides a TickerProvider for testing snap animations.
class _TickerProviderWidget extends StatefulWidget {
  const _TickerProviderWidget({required this.onBuild});

  final void Function(TickerProvider vsync) onBuild;

  @override
  State<_TickerProviderWidget> createState() => _TickerProviderWidgetState();
}

class _TickerProviderWidgetState extends State<_TickerProviderWidget>
    with TickerProviderStateMixin {
  bool _built = false;

  @override
  Widget build(BuildContext context) {
    if (!_built) {
      _built = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onBuild(this);
      });
    }
    return const SizedBox.shrink();
  }
}
