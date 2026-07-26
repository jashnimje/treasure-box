import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/models/item.dart';
import '../../../core/data/models/item_category.dart';
import '../../../core/data/repositories/inventory_repository.dart';
import '../../../core/providers/box_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/minecraft_theme.dart';
import '../../../core/widgets/capacity_bar.dart';
import '../../../core/widgets/pixel_icon.dart';
import '../../../core/widgets/pixel_panel.dart';

/// The most recently added items across all boxes.
final recentItemsProvider = StreamProvider<List<FoundItem>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchRecentItems(8);
});

/// Recent items filtered to one box (the Info tab shows only ITS chest).
final boxRecentItemsProvider =
    StreamProvider.family<List<FoundItem>, int>((ref, boxId) {
  return ref
      .watch(inventoryRepositoryProvider)
      .watchRecentItems(40)
      .map((all) => all.where((f) => f.box.id == boxId).take(8).toList());
});

/// Fill level and category breakdown for the active chest.
class ChestStatsCard extends StatelessWidget {
  const ChestStatsCard({
    super.key,
    required this.capacity,
    required this.items,
  });

  final CapacityInfo capacity;
  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;

    final totalQty = items.fold<int>(0, (sum, i) => sum + i.qty);
    final byCategory = <ItemCategory, int>{};
    for (final item in items) {
      byCategory[item.category] = (byCategory[item.category] ?? 0) + 1;
    }
    final categories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount =
        categories.isEmpty ? 1 : categories.first.value.toDouble();

    return PixelPanel(
      fill: mc.headerBar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CapacityBar(used: capacity.used, capacity: capacity.capacity),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatPair(label: 'stacks', value: '${items.length}'),
              const SizedBox(width: 24),
              _StatPair(label: 'items total', value: '$totalQty'),
              const SizedBox(width: 24),
              _StatPair(label: 'slots free', value: '${capacity.remaining}'),
            ],
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final entry in categories) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    PixelIcon(entry.key.defaultIconKey,
                        size: 16, tint: mc.stoneLight),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 96,
                      child: Text(
                        entry.key.label,
                        style: text.bodyReadable
                            .copyWith(color: mc.stoneLight, fontSize: 15),
                      ),
                    ),
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            (entry.value / maxCount).clamp(0.08, 1.0),
                        child: Container(height: 10, color: mc.grassGreen),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${entry.value}',
                        style: text.numeric.copyWith(color: mc.white)),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatPair extends StatelessWidget {
  const _StatPair({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: text.headingPixel.copyWith(color: mc.gold)),
        const SizedBox(height: 2),
        Text(label,
            style: text.bodyReadable
                .copyWith(color: mc.stoneMid, fontSize: 14)),
      ],
    );
  }
}

/// The latest additions, tapping through to the item. With [boxId] set the
/// list is scoped to that box (Info tab); without it, all boxes (Find).
class RecentItemsCard extends ConsumerWidget {
  const RecentItemsCard({super.key, this.boxId, this.showBoxName = true});

  final int? boxId;
  final bool showBoxName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final text = context.mcText;
    final recent = (boxId == null
            ? ref.watch(recentItemsProvider).valueOrNull
            : ref.watch(boxRecentItemsProvider(boxId!)).valueOrNull) ??
        const [];

    return PixelPanel(
      fill: mc.headerBar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Nothing yet - add your first item from the chest.',
                style: text.bodyReadable.copyWith(color: mc.stoneMid),
              ),
            )
          else
            for (final found in recent)
              InkWell(
                onTap: () {
                  ref
                      .read(activeBoxIdProvider.notifier)
                      .select(found.box.id);
                  context.push('/inventory/item/${found.item.id}');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      PixelIcon(found.item.iconKey,
                          size: 22, tint: mc.stoneLight),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              found.item.name,
                              style: text.bodyReadable
                                  .copyWith(color: mc.white, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              showBoxName
                                  ? '${found.box.name} - '
                                      '${timeAgo(found.item.createdAt)}'
                                  : timeAgo(found.item.createdAt),
                              style: text.bodyReadable.copyWith(
                                  color: mc.stoneMid, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (found.item.qty > 1)
                        Text('x${found.item.qty}',
                            style:
                                text.numeric.copyWith(color: mc.stoneLight)),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Compact "how long ago" label for recent items.
String timeAgo(DateTime when) {
  final d = DateTime.now().difference(when);
  if (d.inDays >= 7) return '${d.inDays ~/ 7}w ago';
  if (d.inDays >= 1) return '${d.inDays}d ago';
  if (d.inHours >= 1) return '${d.inHours}h ago';
  if (d.inMinutes >= 1) return '${d.inMinutes}m ago';
  return 'just now';
}
