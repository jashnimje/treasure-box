import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/data/models/box.dart';
import 'package:treasure_box/core/theme/minecraft_theme.dart';
import 'package:treasure_box/core/widgets/rail_badges.dart';

Box _box({String? nfcTagId, DateTime? qrUsedAt, DateTime? nfcUsedAt}) {
  final now = DateTime(2026, 1, 1);
  return Box(
    id: 1,
    name: 'Treasure Box',
    capacity: 27,
    skinKey: 'oak',
    sortOrder: 0,
    slot: 1,
    qrToken: 'BOX-1',
    nfcTagId: nfcTagId,
    qrUsedAt: qrUsedAt,
    nfcUsedAt: nfcUsedAt,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrap(Widget child) => MaterialApp(
      theme: buildMinecraftTheme(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('unearned rails show only the ID badge', (tester) async {
    await tester.pumpWidget(_wrap(RailBadges(box: _box())));
    expect(find.text('BOX-1'), findsOneWidget);
    expect(find.text('QR'), findsNothing);
    expect(find.text('NFC'), findsNothing);
  });

  testWidgets('QR badge appears once a scan opened the box', (tester) async {
    await tester.pumpWidget(
        _wrap(RailBadges(box: _box(qrUsedAt: DateTime(2026, 1, 2)))));
    expect(find.text('QR'), findsOneWidget);
    expect(find.text('NFC'), findsNothing);
  });

  testWidgets('NFC badge appears when a tag is linked OR was tapped',
      (tester) async {
    await tester.pumpWidget(_wrap(RailBadges(box: _box(nfcTagId: 'AB12'))));
    expect(find.text('NFC'), findsOneWidget);

    await tester.pumpWidget(
        _wrap(RailBadges(box: _box(nfcUsedAt: DateTime(2026, 1, 2)))));
    expect(find.text('NFC'), findsOneWidget);
  });

  testWidgets('compact mode keeps the code text and drops rail labels',
      (tester) async {
    await tester.pumpWidget(_wrap(RailBadges(
      box: _box(nfcTagId: 'AB12', qrUsedAt: DateTime(2026, 1, 2)),
      compact: true,
    )));
    expect(find.text('BOX-1'), findsOneWidget);
    expect(find.text('QR'), findsNothing);
    expect(find.text('NFC'), findsNothing);
    // But the earned rail icons are present.
    expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    expect(find.byIcon(Icons.sensors), findsOneWidget);
  });
}
