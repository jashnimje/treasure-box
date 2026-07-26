import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/data/models/box.dart';
import 'package:treasure_box/core/theme/minecraft_theme.dart';
import 'package:treasure_box/features/home/widgets/room_viewport.dart';

Box _box(int id, String name) => Box(
      id: id,
      name: name,
      capacity: 27,
      skinKey: 'oak',
      sortOrder: id,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  // The viewport reads chest geometry from the layout, so fix the surface.
  const surface = Size(800, 600);

  Future<void> pumpViewport(
    WidgetTester tester, {
    required List<Box> boxes,
    required void Function(int) onTapChest,
    required VoidCallback onTapAdd,
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildMinecraftTheme(),
        home: Scaffold(
          body: RoomViewport(
            boxes: boxes,
            onTapChest: onTapChest,
            onTapAdd: onTapAdd,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  // The first chest starts centered at x = 400; the chest band spans
  // roughly y in [172, 412] for a 600-high viewport (floorY 372).
  const chestCenter = Offset(400, 320);

  group('RoomViewport tap vs pan', () {
    testWidgets('a quick tap on the centered chest opens it', (tester) async {
      int? tapped;
      await pumpViewport(
        tester,
        boxes: [_box(1, 'Treasure Box')],
        onTapChest: (i) => tapped = i,
        onTapAdd: () => fail('add should not fire'),
      );

      await tester.tapAt(chestCenter);
      await tester.pump(const Duration(milliseconds: 50));

      expect(tapped, 0);
    });

    testWidgets('a drag pans the room and does NOT open a chest',
        (tester) async {
      int? tapped;
      await pumpViewport(
        tester,
        boxes: [_box(1, 'A'), _box(2, 'B')],
        onTapChest: (i) => tapped = i,
        onTapAdd: () {},
      );

      // Drag left across the chest: must pan, not tap.
      await tester.dragFrom(chestCenter, const Offset(-250, 0));
      // Let the snap animation finish (fixed pump: ambient tickers never settle).
      await tester.pump(const Duration(milliseconds: 500));

      expect(tapped, isNull);
    });

    testWidgets('tapping still works after a drag', (tester) async {
      int? tapped;
      await pumpViewport(
        tester,
        boxes: [_box(1, 'A'), _box(2, 'B')],
        onTapChest: (i) => tapped = i,
        onTapAdd: () {},
      );

      // Pan to the second chest (spacing = 0.7 * 800 = 560).
      await tester.dragFrom(chestCenter, const Offset(-560, 0));
      await tester.pump(const Duration(milliseconds: 500));

      // The second chest is now centered; tap it.
      await tester.tapAt(chestCenter);
      await tester.pump(const Duration(milliseconds: 50));

      expect(tapped, 1);
    });

    testWidgets('tapping the ghost add-chest opens the create flow',
        (tester) async {
      var added = false;
      await pumpViewport(
        tester,
        boxes: [_box(1, 'A')],
        onTapChest: (_) => fail('chest should not fire'),
        onTapAdd: () => added = true,
      );

      // Ghost slot sits one spacing right of the last chest (world x = 960);
      // maxOffset centers it, so after the pan it is dead-center.
      await tester.dragFrom(chestCenter, const Offset(-560, 0));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tapAt(chestCenter);
      await tester.pump(const Duration(milliseconds: 50));

      expect(added, isTrue);
    });

    testWidgets('tapping empty room space does nothing', (tester) async {
      await pumpViewport(
        tester,
        boxes: [_box(1, 'A')],
        onTapChest: (_) => fail('chest should not fire'),
        onTapAdd: () => fail('add should not fire'),
      );

      // Top-left corner: wall, far from any chest band.
      await tester.tapAt(const Offset(40, 40));
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('zero boxes: the ghost chest is centered and tappable',
        (tester) async {
      var added = false;
      await pumpViewport(
        tester,
        boxes: const [],
        onTapChest: (_) => fail('chest should not fire'),
        onTapAdd: () => added = true,
      );

      await tester.tapAt(chestCenter);
      await tester.pump(const Duration(milliseconds: 50));

      expect(added, isTrue);
    });
  });

  group('RoomViewport layout', () {
    testWidgets('renders a chest name chip and the ghost "New chest" label',
        (tester) async {
      await pumpViewport(
        tester,
        boxes: [_box(1, 'Treasure Box')],
        onTapChest: (_) {},
        onTapAdd: () {},
      );

      expect(find.text('Treasure Box'), findsOneWidget);
      expect(find.text('New chest'), findsOneWidget);
    });
  });
}
