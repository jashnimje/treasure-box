import 'package:flutter/material.dart';

import '../theme/minecraft_theme.dart';

/// The chest capacity bar: a `used/capacity` count plus a fill bar that turns
/// redstone above 80%. The single visual source of the slot count.
class CapacityBar extends StatelessWidget {
  const CapacityBar({
    super.key,
    required this.used,
    required this.capacity,
  });

  final int used;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final fraction = capacity == 0 ? 0.0 : (used / capacity).clamp(0.0, 1.0);
    final nearFull = fraction > 0.8;
    final fillColor = nearFull ? mc.redstone : mc.xpGreen;

    return Row(
      children: [
        Text(
          '$used/$capacity',
          style: context.mcText.numeric.copyWith(color: mc.stoneLight),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: mc.obsidian,
              border: Border.all(color: mc.stoneDark, width: 2),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction == 0 ? 0.0001 : fraction,
                child: Container(
                  color: fillColor,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      heightFactor: 0.4,
                      widthFactor: 1,
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
