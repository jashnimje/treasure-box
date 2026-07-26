// Renders the app icon PNGs from the real chest painter. Not a test of
// behavior - a build tool that runs inside the Flutter test harness (the
// only place we can rasterize widgets without a device):
//
//   flutter test test/tools/render_icon_test.dart
//
// Outputs (committed as assets, consumed by flutter_launcher_icons):
//   assets/icon/icon-full.png       1024x1024, chest on cave backdrop
//   assets/icon/icon-foreground.png 1024x1024, chest alone (adaptive fg)
@Tags(['icon-tool'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/widgets/minecraft_chest.dart';

Future<void> _renderToFile(
  WidgetTester tester,
  Widget widget,
  String path,
) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: key,
        child: SizedBox(width: 1024, height: 1024, child: widget),
      ),
    ),
  );
  await tester.pump();

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage();
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path);
  await file.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render app icon PNGs', (tester) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Full icon: closed chest, hero-sized, on the cave-dark backdrop.
    await tester.runAsync(() => _renderToFile(
          tester,
          Container(
            color: const Color(0xFF17151D),
            alignment: Alignment.center,
            child: const MinecraftChest(size: 780),
          ),
          'assets/icon/icon-full.png',
        ));

    // Adaptive foreground: chest alone on transparency, smaller so the
    // launcher's mask (which crops ~66% center) never clips it.
    await tester.runAsync(() => _renderToFile(
          tester,
          Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            child: const MinecraftChest(size: 560),
          ),
          'assets/icon/icon-foreground.png',
        ));
  }, tags: ['icon-tool']);
}
