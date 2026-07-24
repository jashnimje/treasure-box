import 'package:flutter/material.dart';

import 'pixel_sprite.dart';

/// Paints a [PixelSprite] by drawing each cell as a crisp (anti-alias off)
/// rectangle scaled to the widget size. Because it paints rects rather than a
/// scaled bitmap, edges stay sharp at any size.
class PixelIconPainter extends CustomPainter {
  const PixelIconPainter(this.sprite, {this.tint});

  final PixelSprite sprite;

  /// When set, overrides every cell color (opacity preserved) - handy for
  /// single-color glyphs like nav icons.
  final Color? tint;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / sprite.gridW;
    final scaleY = size.height / sprite.gridH;
    final paint = Paint()..isAntiAlias = false;

    for (final cell in sprite.cells) {
      final base = tint ?? cell.color;
      paint.color = base.withValues(alpha: base.a * cell.opacity);
      canvas.drawRect(
        Rect.fromLTWH(
          cell.x * scaleX,
          cell.y * scaleY,
          cell.w * scaleX,
          cell.h * scaleY,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PixelIconPainter oldDelegate) {
    return oldDelegate.sprite != sprite || oldDelegate.tint != tint;
  }
}
