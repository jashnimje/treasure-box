import 'package:flutter/material.dart';

import '../data/models/box.dart';
import '../theme/minecraft_theme.dart';

/// The earned identity rails of a box, as small icon badges.
///
/// Badges are auto-learned from real usage, not declared: the ID badge is
/// always present (the code always works), the QR badge appears once a
/// scanned QR actually opened the box, and the NFC badge once a tag is
/// linked or a tap opened it. So the row answers "how was this box
/// registered" at a glance.
class RailBadges extends StatelessWidget {
  const RailBadges({
    super.key,
    required this.box,
    this.compact = false,
  });

  final Box box;

  /// Compact mode (home name chip): icons only, smaller, no labels.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final badges = <Widget>[
      _RailBadge(
        icon: Icons.tag,
        label: box.code,
        color: mc.gold,
        compact: compact,
      ),
      if (box.hasQrRail)
        _RailBadge(
          icon: Icons.qr_code_2,
          label: 'QR',
          color: mc.stoneLight,
          compact: compact,
        ),
      if (box.hasNfcRail)
        _RailBadge(
          icon: Icons.sensors,
          label: 'NFC',
          color: mc.xpGreen,
          compact: compact,
        ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < badges.length; i++) ...[
          if (i > 0) SizedBox(width: compact ? 5 : 8),
          badges[i],
        ],
      ],
    );
  }
}

class _RailBadge extends StatelessWidget {
  const _RailBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      // Icons only; the ID rail keeps its code text since that IS the label.
      final showText = icon == Icons.tag;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          if (showText) ...[
            const SizedBox(width: 2),
            Text(
              label,
              style: context.mcText.labelPixel
                  .copyWith(color: color, fontSize: 8),
            ),
          ],
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: context.mcText.labelPixel.copyWith(color: color, fontSize: 9),
        ),
      ],
    );
  }
}
