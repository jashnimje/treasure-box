import 'package:flutter/material.dart';

import '../../../core/theme/minecraft_theme.dart';
import '../../../core/widgets/minecraft_chest.dart';

/// One selectable chest type: a stored key and its display name.
class ChestType {
  const ChestType(this.key, this.label);

  final String key;
  final String label;
}

/// The chest types, matching the containers Minecraft actually has: the
/// chest and its double, the trapped pair, the ender chest (never double),
/// and the festive Christmas pair.
const List<ChestType> chestTypes = [
  ChestType('oak', 'Chest'),
  ChestType('oak-large', 'Large Chest'),
  ChestType('trapped', 'Trapped Chest'),
  ChestType('trapped-large', 'Large Trapped'),
  ChestType('ender', 'Ender Chest'),
  ChestType('christmas', 'Christmas'),
  ChestType('christmas-large', 'Large Christmas'),
];

/// Horizontal picker of [chestTypes]; the selected one gets a diamond frame.
class SkinPicker extends StatelessWidget {
  const SkinPicker({
    super.key,
    required this.selectedSkin,
    required this.onSkinSelected,
  });

  /// The selected chest type key (e.g. `trapped-large`).
  final String selectedSkin;
  final ValueChanged<String> onSkinSelected;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final label = context.mcText.labelPixel;
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: chestTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final type = chestTypes[index];
          final isSelected = type.key == selectedSkin;
          final large = ChestSkin.isLarge(type.key);
          return GestureDetector(
            onTap: () => onSkinSelected(type.key),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? mc.diamond : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: SizedBox(
                    width: large ? 110 : 80,
                    height: 92,
                    child: Center(
                      child: MinecraftChest(
                        size: large ? 110 : 80,
                        skinKey: type.key,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type.label,
                  style: label.copyWith(
                    color: isSelected ? mc.diamond : mc.stoneMid,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
