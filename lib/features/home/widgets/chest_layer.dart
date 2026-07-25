import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/data/models/box.dart';
import '../../../core/theme/minecraft_theme.dart';
import '../../../core/widgets/minecraft_chest.dart';
import '../../../core/widgets/rail_badges.dart';

/// Positions [MinecraftChest] widgets at their world-x coordinates minus the
/// camera offset. The chest nearest the viewport center is the focal point:
/// it renders larger, gets a warm torch glow behind it, and bobs idly.
/// Off-center chests shrink and dim so the centered one clearly reads as
/// "this is your chest".
///
/// The trailing slot is a ghost chest - a desaturated, translucent chest with
/// a faint "+" - so adding a box feels like placing another chest in-world.
class ChestLayer extends StatelessWidget {
  const ChestLayer({
    super.key,
    required this.boxes,
    required this.cameraOffset,
    required this.viewportWidth,
    required this.chestPositions,
    required this.focusedIndex,
    required this.idleAnimation,
    this.lidOpenIndex,
    this.lidOpenValue,
    this.chestSize = 190,
  });

  /// List of boxes from boxesProvider.
  final List<Box> boxes;

  /// Current camera x offset.
  final double cameraOffset;

  /// Screen width.
  final double viewportWidth;

  /// World-x position per box (plus the trailing ghost slot).
  final List<double> chestPositions;

  /// Which chest is centered / focused.
  final int focusedIndex;

  /// Animation value for bob (0-1 looping).
  final Animation<double> idleAnimation;

  /// Which chest to animate lid open (null = none).
  final int? lidOpenIndex;

  /// 0-1 lid open amount for that chest.
  final double? lidOpenValue;

  /// Size of each chest widget.
  final double chestSize;

  /// Extra height reserved under the chest for the in-world name chip.
  static const double _labelBand = 40;

  /// 0..1 focus proximity: 1 when the chest sits at the viewport center.
  double _focusT(double worldX) {
    final screenCenterX = worldX - cameraOffset;
    final dist = (screenCenterX - viewportWidth / 2).abs();
    return (1 - dist / (viewportWidth * 0.55)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = constraints.maxHeight;
        // Floor sits at ~62% of viewport height.
        final floorY = viewportHeight * 0.62;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < boxes.length; i++)
              _buildChest(context, i, floorY),
            if (chestPositions.length > boxes.length)
              _buildGhostChest(context, floorY),
          ],
        );
      },
    );
  }

  /// Extra horizontal room beyond the chest so the name chip (name + rail
  /// badges) is not truncated by the chest-width column.
  static const double _chipOverhang = 50;

  Widget _buildChest(BuildContext context, int index, double floorY) {
    final worldX = chestPositions[index];
    final screenX = worldX - cameraOffset - chestSize / 2 - _chipOverhang;
    final baseY = floorY - chestSize * 0.85;
    final t = _focusT(worldX);
    // Focused chest is the hero (~1.08x); the rest recede (~0.78x).
    final scale = 0.78 + 0.30 * t;

    final double lidOpen =
        (lidOpenIndex == index && lidOpenValue != null) ? lidOpenValue! : 0;

    Widget chest = MinecraftChest(
      size: chestSize,
      lidOpen: lidOpen,
      skinKey: boxes[index].skinKey,
    );

    // Idle bob follows focus so only the hero chest breathes.
    if (t > 0.6) {
      chest = AnimatedBuilder(
        animation: idleAnimation,
        builder: (context, child) {
          final bobOffset = math.sin(idleAnimation.value * 2 * math.pi) * 5.0 * t;
          return Transform.translate(
            offset: Offset(0, bobOffset),
            child: child,
          );
        },
        child: chest,
      );
    }

    return Positioned(
      left: screenX,
      top: baseY,
      width: chestSize + 2 * _chipOverhang,
      height: chestSize * 1.05 + _labelBand,
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  // Dim receding chests slightly; hero stays full. Scale-up
                  // and idle bob are the focus cues (no glow: a gradient
                  // fill read as a square against the cave wall).
                  opacity: 0.72 + 0.28 * t,
                  child: SizedBox(
                    width: chestSize,
                    child: chest,
                  ),
                ),
              ),
            ),
          ),
          _NameChip(
            label: boxes[index].name,
            emphasis: t,
            box: boxes[index],
          ),
        ],
      ),
    );
  }

  Widget _buildGhostChest(BuildContext context, double floorY) {
    final mc = context.mc;
    final worldX = chestPositions.last;
    final screenX = worldX - cameraOffset - chestSize / 2;
    final baseY = floorY - chestSize * 0.85;
    final t = _focusT(worldX);
    final scale = 0.74 + 0.22 * t;

    // Desaturate the chest so it reads as a placeholder, not a real box.
    const greyscale = ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]);

    return Positioned(
      left: screenX,
      top: baseY,
      width: chestSize,
      height: chestSize * 1.05 + _labelBand,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: 0.30 + 0.14 * t,
                      child: ColorFiltered(
                        colorFilter: greyscale,
                        child: MinecraftChest(size: chestSize),
                      ),
                    ),
                  ),
                ),
                // Faint "+" floating over the ghost.
                Opacity(
                  opacity: 0.45 + 0.35 * t,
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: chestSize * 0.30,
                      fontWeight: FontWeight.bold,
                      color: mc.stoneLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _NameChip(label: 'New chest', emphasis: t, muted: true),
        ],
      ),
    );
  }
}

/// A small in-world label chip anchored under a chest, embedded into the
/// scene with a translucent dark fill rather than floating like a card.
/// When [box] is set, its earned rail badges render beside the name so the
/// room shows how each box was registered.
class _NameChip extends StatelessWidget {
  const _NameChip({
    required this.label,
    required this.emphasis,
    this.box,
    this.muted = false,
  });

  final String label;

  /// 0..1 focus proximity; the chip brightens toward the focal chest.
  final double emphasis;
  final Box? box;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final textColor = muted
        ? mc.stoneMid
        : Color.lerp(mc.stoneLight, mc.white, emphasis)!;
    return Opacity(
      opacity: 0.55 + 0.45 * emphasis,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: mc.obsidianDeep.withValues(alpha: 0.72),
          border: Border.all(
            color: mc.obsidianLight.withValues(alpha: 0.8),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.mcText.bodyReadable.copyWith(
                  color: textColor,
                  fontSize: 17,
                ),
              ),
            ),
            if (box != null) ...[
              const SizedBox(width: 7),
              RailBadges(box: box!, compact: true),
            ],
          ],
        ),
      ),
    );
  }
}
