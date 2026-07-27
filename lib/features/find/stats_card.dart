import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/backup/backup_codec.dart';
import '../../core/data/models/item.dart';
import '../../core/data/models/item_category.dart';
import '../../core/data/models/rarity.dart';
import '../../core/game/mine_points.dart';
import '../../core/providers/box_providers.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/pixel_panel.dart';

/// Everything in every box, recomputed when boxes change.
final _statsProvider = FutureProvider<Backup>((ref) {
  ref.watch(boxesProvider);
  return ref.watch(inventoryRepositoryProvider).exportBackup();
});

/// Cross-box statistics, in the spirit of the game's stats screen: how much
/// stuff of what kinds, how full the chests are, and the crown jewel.
class StatsCard extends ConsumerWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final stats = ref.watch(_statsProvider).valueOrNull;
    final points = ref.watch(minePointsProvider);

    if (stats == null) return const SizedBox.shrink();

    var totalQty = 0;
    var usedSlots = 0;
    var totalSlots = 0;
    String? fullestBox;
    var fullestCount = -1;
    final categories = <ItemCategory>{};
    Item? rarest;
    for (final b in stats.boxes) {
      totalSlots += b.box.capacity;
      usedSlots += b.items.length;
      for (final item in b.items) {
        totalQty += item.qty;
        categories.add(item.category);
        if (rarest == null || item.rarity.index > rarest.rarity.index) {
          rarest = item;
        }
      }
      if (b.items.length > fullestCount) {
        fullestCount = b.items.length;
        fullestBox = b.box.name;
      }
    }

    return PixelPanel(
      fill: mc.headerBar,
      child: Column(
        children: [
          _StatRow('Chests', '${stats.boxes.length}'),
          _StatRow('Items stashed',
              '${stats.itemCount} ($totalQty counting stacks)'),
          _StatRow('Slots filled', '$usedSlots of $totalSlots'),
          _StatRow('Categories in use',
              '${categories.length} of ${ItemCategory.values.length}'),
          if (rarest != null && rarest.rarity != Rarity.common)
            _StatRow('Rarest treasure', rarest.name,
                valueColor: rarest.rarity.color(mc)),
          if (fullestBox != null && stats.boxes.length > 1)
            _StatRow('Fullest chest', fullestBox),
          _StatRow('Ores mined', '$points pts'),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value, {this.valueColor});

  final String label;
  final String value;

  /// Value tint (e.g. the rarity color of the rarest treasure).
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label,
              style: text.bodyReadable
                  .copyWith(color: mc.stoneLight, fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.numeric.copyWith(color: valueColor ?? mc.gold),
            ),
          ),
        ],
      ),
    );
  }
}
