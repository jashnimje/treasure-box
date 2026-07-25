import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/box_providers.dart';
import '../../core/providers/inventory_query_provider.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/minecraft_chest.dart';
import '../../core/widgets/pixel_text_field.dart';
import 'widgets/chest_header.dart';
import 'widgets/inventory_filter_sheet.dart';
import 'widgets/inventory_item_tile.dart';

/// The chest inventory: header + search + filter + item list.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final box = ref.watch(boxStreamProvider).valueOrNull;
    final capacity = ref.watch(capacityProvider);
    final filtered = ref.watch(filteredItemsProvider);
    final query = ref.watch(inventoryQueryProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [mc.obsidian, mc.obsidianDeep],
        ),
      ),
      child: Column(
        children: [
          ChestHeader(
            boxName: box?.name ?? 'Treasure Box',
            used: capacity.used,
            capacity: capacity.capacity,
            box: box,
            skinKey: box?.skinKey ?? 'oak',
            onTapTitle: () => context.go('/'),
          ),
          _SearchRow(
            controller: _searchController,
            onChanged: (v) =>
                ref.read(inventoryQueryProvider.notifier).setSearch(v),
            filtering: query.isFiltering,
            onFilter: () => InventoryFilterSheet.show(context),
          ),
          Expanded(
            child: filtered.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: context.mcText.bodyReadable
                        .copyWith(color: mc.redstone)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(
                    filtering: query.isFiltering,
                    skinKey: box?.skinKey ?? 'oak',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return _EmptySlotsHint(remaining: capacity.remaining);
                    }
                    final item = items[index];
                    return InventoryItemTile(
                      item: item,
                      onTap: () => context.push('/inventory/item/${item.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.filtering,
    required this.onFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool filtering;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Container(
      color: mc.obsidian,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: PixelTextField(
              controller: controller,
              hintText: 'Search items...',
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFilter,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: mc.obsidianLight,
                border: Border.all(
                  color: filtering ? mc.diamond : mc.stoneDark,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.tune,
                color: filtering ? mc.diamond : mc.stoneLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlotsHint extends StatelessWidget {
  const _EmptySlotsHint({required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Text(
          '$remaining empty slots',
          style: context.mcText.bodyReadable.copyWith(color: context.mc.stoneDark),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtering, this.skinKey = 'oak'});

  final bool filtering;

  /// The box's own skin so the empty chest matches the one just opened.
  final String skinKey;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The chest you just opened: same skin, lid open, looking inside.
          Opacity(
            opacity: 0.6,
            child: SizedBox(
              width: 110,
              height: 116,
              child: FittedBox(
                fit: BoxFit.contain,
                child:
                    MinecraftChest(size: 110, lidOpen: 1, skinKey: skinKey),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            filtering ? 'No matching items' : 'The chest is empty',
            style: text.headingPixel.copyWith(color: mc.stoneMid),
          ),
          const SizedBox(height: 12),
          Text(
            filtering
                ? 'Try a different search or filter'
                : 'Tap + to stash your first item',
            style: text.bodyReadable.copyWith(color: mc.stoneDark),
          ),
        ],
      ),
    );
  }
}
