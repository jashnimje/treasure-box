import 'package:flutter/material.dart';

import '../../../core/data/models/box.dart';
import '../../../core/theme/minecraft_theme.dart';
import '../../../core/widgets/capacity_bar.dart';
import '../../../core/widgets/minecraft_chest.dart';
import '../../../core/widgets/rail_badges.dart';

/// The inventory header: mini chest, box name, earned rail badges (how this
/// box was actually registered - code always, QR/NFC once used), and the
/// capacity bar. The whole title band - including its padding, all the way
/// into the top-left corner - is one tap target that returns to the room via
/// [onTapTitle].
class ChestHeader extends StatelessWidget {
  const ChestHeader({
    super.key,
    required this.boxName,
    required this.used,
    required this.capacity,
    this.box,
    this.skinKey = 'oak',
    this.onTapTitle,
  });

  final String boxName;
  final int used;
  final int capacity;

  /// The box, for its earned rail badges. Null while loading.
  final Box? box;
  final String skinKey;
  final VoidCallback? onTapTitle;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return Container(
      color: mc.headerBar,
      child: Column(
        children: [
          // The full-width title band is the back-to-room tap target; the
          // GestureDetector wraps the padding so the top-left corner counts.
          GestureDetector(
            onTap: onTapTitle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  MiniChest(size: 38, skinKey: skinKey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          boxName,
                          style: text.headingPixel,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        if (box != null) RailBadges(box: box!),
                      ],
                    ),
                  ),
                  Icon(Icons.meeting_room_outlined,
                      color: mc.stoneMid, size: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: CapacityBar(used: used, capacity: capacity),
          ),
        ],
      ),
    );
  }
}

