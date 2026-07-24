import 'package:flutter/material.dart';

import 'pixel_icon_painter.dart';
import 'pixel_sprite.dart';

/// Renders a Minecraft pixel icon by [spriteKey]. Falls back to the `book`
/// sprite if the key is unknown, so a bad key never crashes the UI.
class PixelIcon extends StatelessWidget {
  const PixelIcon(
    this.spriteKey, {
    super.key,
    this.size = 32,
    this.tint,
  });

  final String spriteKey;
  final double size;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final sprite = pixelSprites[spriteKey] ?? pixelSprites['book']!;
    // Preserve the sprite's aspect ratio within the requested box.
    final aspect = sprite.gridW / sprite.gridH;
    final width = aspect >= 1 ? size : size * aspect;
    final height = aspect >= 1 ? size / aspect : size;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: CustomPaint(
          size: Size(width, height),
          painter: PixelIconPainter(sprite, tint: tint),
        ),
      ),
    );
  }
}
