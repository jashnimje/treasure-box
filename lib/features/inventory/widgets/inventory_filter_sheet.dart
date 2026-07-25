import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/inventory_query.dart';
import '../../../core/data/models/item_category.dart';
import '../../../core/providers/inventory_query_provider.dart';
import '../../../core/theme/minecraft_theme.dart';

/// Bottom sheet with category filter chips and sort options. Reads and writes
/// the [inventoryQueryProvider].
class InventoryFilterSheet extends ConsumerWidget {
  const InventoryFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: context.mc.headerBar,
      isScrollControlled: true,
      builder: (_) => const InventoryFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final text = context.mcText;
    final query = ref.watch(inventoryQueryProvider);
    final notifier = ref.read(inventoryQueryProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CATEGORY', style: text.labelPixel.copyWith(color: mc.stoneMid)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  label: 'All',
                  selected: query.category == null,
                  onTap: () => notifier.setCategory(null),
                ),
                for (final c in ItemCategory.values)
                  _Chip(
                    label: c.label,
                    selected: query.category == c,
                    onTap: () => notifier.setCategory(c),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('SORT BY', style: text.labelPixel.copyWith(color: mc.stoneMid)),
            const SizedBox(height: 12),
            for (final s in SortKey.values)
              RadioListTile<SortKey>(
                contentPadding: EdgeInsets.zero,
                value: s,
                groupValue: query.sort,
                activeColor: mc.diamond,
                title: Text(
                  s.label,
                  style: text.bodyReadable.copyWith(color: mc.white),
                ),
                onChanged: (v) {
                  if (v != null) notifier.setSort(v);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? mc.obsidianLight : mc.obsidian,
          border: Border.all(
            color: selected ? mc.diamond : mc.stoneDark,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: context.mcText.bodyReadable.copyWith(
            color: selected ? mc.diamond : mc.stoneLight,
          ),
        ),
      ),
    );
  }
}
