import 'package:flutter/material.dart';

/// Paints the four beveled edge strips that give Minecraft UI its 3D look,
/// replicating the mock's `inset` box-shadows (which Flutter has no native
/// equivalent for).
///
/// Raised: light on top/left, dark on bottom/right. Set [pressed] to invert the
/// direction for a pushed-in look.
class BevelPainter extends CustomPainter {
  const BevelPainter({
    required this.light,
    required this.dark,
    this.thickness = 3,
    this.pressed = false,
  });

  final Color light;
  final Color dark;
  final double thickness;
  final bool pressed;

  @override
  void paint(Canvas canvas, Size size) {
    final t = thickness;
    final topLeft = pressed ? dark : light;
    final bottomRight = pressed ? light : dark;
    final paint = Paint()..isAntiAlias = false;

    // Top edge.
    paint.color = topLeft;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, t), paint);
    // Left edge.
    canvas.drawRect(Rect.fromLTWH(0, 0, t, size.height), paint);

    // Bottom edge.
    paint.color = bottomRight;
    canvas.drawRect(Rect.fromLTWH(0, size.height - t, size.width, t), paint);
    // Right edge.
    canvas.drawRect(Rect.fromLTWH(size.width - t, 0, t, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant BevelPainter oldDelegate) {
    return oldDelegate.light != light ||
        oldDelegate.dark != dark ||
        oldDelegate.thickness != thickness ||
        oldDelegate.pressed != pressed;
  }
}
