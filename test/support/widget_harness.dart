import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/data/app_database.dart';
import 'package:treasure_box/core/providers/database_providers.dart';
import 'package:treasure_box/core/theme/minecraft_theme.dart';

/// Pumps [child] inside a ProviderScope (with the in-memory [db]) and a
/// MaterialApp carrying the Minecraft theme. The child is wrapped in a Scaffold
/// so screens that assume a Material ancestor render correctly.
Widget wrapForTest({required AppDatabase db, required Widget child}) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: buildMinecraftTheme(),
      home: Scaffold(body: child),
    ),
  );
}

/// Unmount the app within the test body so Drift's stream-close timer (scheduled
/// during ProviderScope disposal) flushes before the test-end timer check.
/// Call at the end of a widget test that watches a Drift stream.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  // Let Drift's zero-duration stream-close timer fire before the invariant check.
  await tester.pump(const Duration(milliseconds: 10));
}

/// Give the test a tall surface so long scrollable forms render their bottom
/// controls (e.g. the Save button) without manual scrolling.
void useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
