import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A Minecraft "world-loading" style page transition.
///
/// Draws an 8x8 grid of opaque blocks over the screen and removes them
/// column-by-column as [animation] progresses from 0.0 to 1.0, revealing
/// the new page beneath.
class BlockWipeTransition extends StatelessWidget {
  const BlockWipeTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        // IgnorePointer is load-bearing: a CustomPaint with a painter is
        // opaque to hit testing (hitTestSelf returns true), so without it
        // this invisible overlay swallows every tap on the page beneath it.
        IgnorePointer(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) => CustomPaint(
              painter: _BlockWipePainter(
                1.0 - animation.value,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints opaque blocks in an 8x8 grid. [coverageProgress] controls how many
/// columns remain visible: 1.0 = all blocks drawn (page hidden),
/// 0.0 = no blocks drawn (page fully revealed).
///
/// Blocks are removed column-by-column left-to-right. Colors alternate between
/// stone-dark and obsidian tones for a Minecraft chunk-loading feel.
class _BlockWipePainter extends CustomPainter {
  _BlockWipePainter(this.coverageProgress);

  final double coverageProgress;

  static const int _cols = 8;
  static const int _rows = 8;

  // Stone-dark and obsidian palette for the loading blocks.
  static const List<Color> _blockColors = [
    Color(0xFF5A5A5A), // stoneDark
    Color(0xFF1D1A24), // obsidian
    Color(0xFF2E2A38), // obsidianLight
    Color(0xFF4A4A4A), // stone darker variant
    Color(0xFF3A3548), // obsidian mid
    Color(0xFF5A5A5A), // stoneDark repeat
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (coverageProgress <= 0.0) return;

    final blockWidth = size.width / _cols;
    final blockHeight = size.height / _rows;

    // Number of columns still covered (fractional for smooth wipe).
    final coveredCols = (coverageProgress * _cols).ceil().clamp(0, _cols);

    final paint = Paint()..style = PaintingStyle.fill;
    final rng = Random(42); // Deterministic seed for consistent block colors.

    for (int col = 0; col < coveredCols; col++) {
      for (int row = 0; row < _rows; row++) {
        // Pick a deterministic color based on position.
        final colorIndex = (col * _rows + row + rng.nextInt(3)) % _blockColors.length;
        paint.color = _blockColors[colorIndex];

        final rect = Rect.fromLTWH(
          col * blockWidth,
          row * blockHeight,
          blockWidth + 1, // +1 to avoid subpixel gaps
          blockHeight + 1,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BlockWipePainter oldDelegate) {
    return oldDelegate.coverageProgress != coverageProgress;
  }
}

/// Helper that wraps a [child] widget in a [CustomTransitionPage] using the
/// block-wipe transition animation.
CustomTransitionPage<T> blockWipePage<T>(Widget child) {
  return CustomTransitionPage<T>(
    child: child,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return BlockWipeTransition(
        animation: animation,
        child: child,
      );
    },
  );
}
