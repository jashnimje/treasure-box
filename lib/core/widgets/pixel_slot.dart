import 'package:flutter/material.dart';

import '../theme/minecraft_theme.dart';

/// A recessed inventory slot: dark inner fill with a sunken bevel and an
/// optional selected (diamond) ring. Used for icon slots, picker cells, and the
/// item-detail hero.
class PixelSlot extends StatelessWidget {
  const PixelSlot({
    super.key,
    required this.child,
    this.size,
    this.selected = false,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final double? size;
  final bool selected;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final content = Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        color: mc.slotInner,
        border: Border(
          // Sunken: dark top/left, lighter bottom/right.
          top: BorderSide(color: Colors.black.withValues(alpha: 0.6), width: 2),
          left:
              BorderSide(color: Colors.black.withValues(alpha: 0.6), width: 2),
          right: BorderSide(color: mc.slotBorder, width: 2),
          bottom: BorderSide(color: mc.slotBorder, width: 2),
        ),
      ),
      child: Center(child: child),
    );

    final framed = selected
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(color: mc.diamond, width: 2),
            ),
            child: content,
          )
        : content;

    if (onTap == null) return framed;
    return GestureDetector(onTap: onTap, child: framed);
  }
}
