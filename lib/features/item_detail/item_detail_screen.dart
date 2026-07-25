import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/models/item.dart';
import '../../core/providers/box_providers.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/item_image.dart';
import '../../core/widgets/pixel_button.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/widgets/pixel_panel.dart';
import '../../core/widgets/pixel_slot.dart';
import 'widgets/delete_confirm_dialog.dart';

/// Item detail: large hero, rarity, stats, notes, and edit/remove actions.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    // Resolve the item from the current live list so it updates after edits.
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final item = items.where((i) => i.id == itemId).firstOrNull;

    return Scaffold(
      backgroundColor: mc.voidDark,
      appBar: _DetailAppBar(title: item?.name ?? 'Item'),
      body: item == null
          ? Center(
              child: Text('Item not found',
                  style: context.mcText.bodyReadable
                      .copyWith(color: mc.stoneMid)),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [mc.obsidian, mc.obsidianDeep],
                ),
              ),
              child: _DetailBody(item: item),
            ),
    );
  }
}

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return AppBar(
      backgroundColor: mc.headerBar,
      foregroundColor: mc.white,
      titleSpacing: 0,
      title: Text('Item detail', style: context.mcText.headingPixel),
      shape: Border(bottom: BorderSide(color: mc.obsidianLight, width: 3)),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.item});

  final Item item;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await DeleteConfirmDialog.show(context, item);
    if (confirmed == true) {
      await ref.read(inventoryRepositoryProvider).deleteItem(item.id);
      if (context.mounted) Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final text = context.mcText;
    final rarityColor = item.rarity.color(mc);

    return ListView(
      children: [
        // Hero with radial glow
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xF010081F),
                mc.obsidian,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              // Radial glow behind the item icon based on rarity
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withValues(alpha: 0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: PixelSlot(size: 110, child: ItemImage(item: item, size: 96)),
              ),
              const SizedBox(height: 16),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: text.displayPixel.copyWith(color: rarityColor),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 12, color: mc.gold),
                  const SizedBox(width: 6),
                  Text(item.rarity.label,
                      style: text.labelPixel.copyWith(color: rarityColor)),
                  const SizedBox(width: 6),
                  Icon(Icons.auto_awesome, size: 12, color: mc.gold),
                ],
              ),
            ],
          ),
        ),
        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatCell(label: 'CATEGORY', value: item.category.label),
            ),
            Expanded(
              child: _StatCell(
                label: 'IN CHEST',
                value: 'x${item.qty}',
                valueColor: mc.gold,
              ),
            ),
          ],
        ),
        if ((item.notes ?? '').trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: PixelPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NOTES',
                      style: text.labelPixel.copyWith(color: mc.stoneMid)),
                  const SizedBox(height: 8),
                  Text(item.notes!,
                      style: text.bodyReadable.copyWith(color: mc.white)),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            'Added ${_formatDate(item.createdAt)}',
            style: text.bodyReadable.copyWith(color: mc.stoneDark),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              PixelButton(
                width: double.infinity,
                onPressed: () => context.push('/add?editId=${item.id}'),
                child: Text('Edit item',
                    style: text.labelPixel.copyWith(color: mc.white)),
              ),
              const SizedBox(height: 10),
              PixelButton(
                variant: PixelButtonVariant.redstone,
                width: double.infinity,
                onPressed: () => _delete(context, ref),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PixelIcon('tnt', size: 16),
                    const SizedBox(width: 8),
                    Text('Remove from chest',
                        style: text.labelPixel.copyWith(color: mc.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mc.headerBar,
        border: Border(bottom: BorderSide(color: mc.stoneDark, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelPixel.copyWith(color: mc.stoneMid, fontSize: 10)),
          const SizedBox(height: 6),
          Text(value,
              style: text.bodyReadable
                  .copyWith(color: valueColor ?? mc.plankLight)),
        ],
      ),
    );
  }
}
