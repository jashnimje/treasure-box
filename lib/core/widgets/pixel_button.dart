import 'package:flutter/material.dart';

import '../theme/minecraft_colors.dart';
import '../theme/minecraft_theme.dart';
import 'bevel_painter.dart';

/// Color variants for a [PixelButton], matching the mock's stone/plank/grass/
/// redstone/diamond buttons.
enum PixelButtonVariant { stone, plank, grass, redstone, diamond }

/// A Minecraft-style beveled button. Presses in (bevel inverts + 2px drop) on
/// tap-down, exactly like the mock's `StoneButton`.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = PixelButtonVariant.stone,
    this.height = 48,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final VoidCallback? onPressed;
  final PixelButtonVariant variant;
  final double height;
  final double? width;
  final EdgeInsets padding;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  Color _baseColor(MinecraftColors mc) {
    switch (widget.variant) {
      case PixelButtonVariant.stone:
        return mc.stoneMid;
      case PixelButtonVariant.plank:
        return mc.plankTan;
      case PixelButtonVariant.grass:
        return mc.grassGreen;
      case PixelButtonVariant.redstone:
        return mc.redstone;
      case PixelButtonVariant.diamond:
        return mc.diamond;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final enabled = widget.onPressed != null;
    final base = _baseColor(mc);
    final color = enabled ? base : MinecraftColors.darken(base, 30);
    final light = MinecraftColors.lighten(color, 40);
    final dark = MinecraftColors.darken(color, 45);

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 40),
          width: widget.width,
          height: widget.height,
          transform:
              Matrix4.translationValues(0, _pressed && enabled ? 2 : 0, 0),
          color: color,
          child: CustomPaint(
            foregroundPainter: BevelPainter(
              light: light,
              dark: dark,
              thickness: 3,
              pressed: _pressed && enabled,
            ),
            child: Padding(
              padding: widget.padding,
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
