import 'package:flutter/material.dart';

import '../theme/minecraft_theme.dart';

/// A framed container for header bars, cards, and modals. Draws a raised look
/// with a solid fill and an optional accent border (e.g. redstone for danger,
/// diamond for selected).
class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.fill,
    this.borderColor,
    this.borderWidth = 2,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color? fill;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill ?? mc.obsidianLight,
        border: Border.all(
          color: borderColor ?? mc.stoneDark,
          width: borderWidth,
        ),
      ),
      child: child,
    );
  }
}
