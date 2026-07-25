import 'package:flutter/material.dart';

import '../../../core/data/models/item.dart';
import '../../../core/theme/minecraft_theme.dart';
import '../../../core/widgets/item_image.dart';
import '../../../core/widgets/pixel_slot.dart';

/// A single row in the inventory list: icon/photo slot, name + category, and a
/// gold quantity badge.
class InventoryItemTile extends StatelessWidget {
  const InventoryItemTile({super.key, required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mc.obsidianLight,
          border: Border.all(color: const Color(0xFF33303C), width: 2),
        ),
        child: Row(
          children: [
            PixelSlot(size: 48, child: ItemImage(item: item, size: 44)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: text.labelPixel.copyWith(color: mc.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.category.label,
                    style: text.bodyReadable.copyWith(color: mc.stoneMid),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: mc.obsidian,
                border: Border.all(color: mc.stoneDark, width: 2),
              ),
              child: Text(
                'x${item.qty}',
                style: text.numeric.copyWith(color: mc.gold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
