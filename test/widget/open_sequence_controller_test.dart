import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/features/home/open_sequence_controller.dart';

void main() {
  group('OpenSequenceController', () {
    testWidgets('starts in idle phase with isActive false', (tester) async {
      final harness = await _createHarness(tester);

      expect(harness.controller.phase, OpenSequencePhase.idle);
      expect(harness.controller.isActive, isFalse);
    });

    testWidgets('initial derived values are at idle state', (tester) async {
      final harness = await _createHarness(tester);

      expect(harness.controller.lidOpenValue, 0.0);
      expect(harness.controller.pushScale, 1.0);
    });

    testWidgets('start() runs lid then dwell, then completes', (tester) async {
      bool completed = false;
      final harness = await _createHarness(
        tester,
        onComplete: () => completed = true,
      );
      final c = harness.controller;

      c.start();
      expect(c.phase, OpenSequencePhase.lid);
      expect(c.isActive, isTrue);

      // Advance past lid (550ms)
      await _pumpPastPhase(tester, 600);
      expect(c.phase, OpenSequencePhase.dwell);
      expect(completed, isFalse);

      // Advance past dwell (500ms)
      await _pumpPastPhase(tester, 550);
      expect(completed, isTrue);
    });

    testWidgets('start() is a no-op when already active', (tester) async {
      final harness = await _createHarness(tester);
      final c = harness.controller;

      c.start();
      expect(c.phase, OpenSequencePhase.lid);

      c.start();
      expect(c.phase, OpenSequencePhase.lid);
    });

    testWidgets('lidOpenValue reaches 1.0 at full open; push stays subtle',
        (tester) async {
      final harness = await _createHarness(tester);
      final c = harness.controller;

      c.start();
      await _pumpPastPhase(tester, 600); // lid
      expect(c.lidOpenValue, closeTo(1.0, 0.01));

      await _pumpPastPhase(tester, 550); // dwell
      // The world never warps: push-in tops out at 1.06.
      expect(c.pushScale, closeTo(1.06, 0.01));
    });

    testWidgets('cancel() reverses and returns all values to idle',
        (tester) async {
      final harness = await _createHarness(tester);
      final c = harness.controller;

      c.start();
      await _pumpFrames(tester, 18); // ~288ms into lid
      expect(c.lidOpenValue, greaterThan(0.0));

      c.cancel();
      expect(c.phase, OpenSequencePhase.idle);
      expect(c.isActive, isFalse);

      await _pumpPastPhase(tester, 700);

      expect(c.lidOpenValue, 0.0);
      expect(c.pushScale, 1.0);
    });

    testWidgets('cancel() during dwell does not fire onComplete',
        (tester) async {
      bool completed = false;
      final harness = await _createHarness(
        tester,
        onComplete: () => completed = true,
      );
      final c = harness.controller;

      c.start();
      await _pumpPastPhase(tester, 600); // into dwell
      expect(c.phase, OpenSequencePhase.dwell);

      c.cancel();
      await _pumpPastPhase(tester, 700);

      expect(completed, isFalse);
      expect(c.lidOpenValue, 0.0);
    });

    testWidgets('notifies listeners on animation frame updates',
        (tester) async {
      final harness = await _createHarness(tester);
      final c = harness.controller;

      int notifyCount = 0;
      c.addListener(() => notifyCount++);

      c.start();
      expect(notifyCount, greaterThan(0));

      final countAfterStart = notifyCount;
      await _pumpFrames(tester, 5);
      expect(notifyCount, greaterThan(countAfterStart));
    });

    testWidgets('reset() immediately returns all values to idle',
        (tester) async {
      final harness = await _createHarness(tester);
      final c = harness.controller;

      c.start();
      await _pumpFrames(tester, 18);
      expect(c.lidOpenValue, greaterThan(0.0));

      c.reset();
      expect(c.phase, OpenSequencePhase.idle);
      expect(c.lidOpenValue, 0.0);
      expect(c.pushScale, 1.0);
    });
  });
}

/// Pumps [count] frames of 16ms each.
Future<void> _pumpFrames(WidgetTester tester, int count) async {
  for (int i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Pumps frames until [totalMs] has elapsed, advancing in 16ms steps.
Future<void> _pumpPastPhase(WidgetTester tester, int totalMs) async {
  final frames = (totalMs / 16).ceil();
  await _pumpFrames(tester, frames);
}

/// Test harness holding the controller reference.
class _Harness {
  _Harness(this.controller);
  final OpenSequenceController controller;
}

/// Creates an [OpenSequenceController] properly managed by a widget lifecycle.
Future<_Harness> _createHarness(
  WidgetTester tester, {
  VoidCallback? onComplete,
}) async {
  late OpenSequenceController controller;

  await tester.pumpWidget(
    MaterialApp(
      home: _ControllerHost(
        onComplete: onComplete,
        onCreated: (c) => controller = c,
      ),
    ),
  );

  await tester.pump();
  return _Harness(controller);
}

/// A stateful widget that creates and owns the [OpenSequenceController],
/// disposing it properly when the widget is removed from the tree.
class _ControllerHost extends StatefulWidget {
  const _ControllerHost({this.onComplete, required this.onCreated});

  final VoidCallback? onComplete;
  final void Function(OpenSequenceController) onCreated;

  @override
  State<_ControllerHost> createState() => _ControllerHostState();
}

class _ControllerHostState extends State<_ControllerHost>
    with TickerProviderStateMixin {
  late final OpenSequenceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OpenSequenceController(
      vsync: this,
      onComplete: widget.onComplete,
    );
    widget.onCreated(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
