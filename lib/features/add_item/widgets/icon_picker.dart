import 'package:flutter/material.dart';

import '../../../core/theme/minecraft_theme.dart';
import '../../../core/widgets/pixel_icon.dart';
import '../../../core/widgets/pixel_slot.dart';

/// The eight selectable pixel icons, matching the mock's picker.
const List<String> pickableIconKeys = [
  'sword',
  'pickaxe',
  'ingot',
  'gem',
  'potion',
  'book',
  'apple',
  'tnt',
];

/// A grid of pixel-icon slots; the selected one gets a diamond ring.
class IconPicker extends StatelessWidget {
  const IconPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: mc.headerBar,
        border: Border.all(color: mc.stoneDark, width: 2),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final key in pickableIconKeys)
            PixelSlot(
              size: 44,
              selected: key == selected,
              onTap: () => onSelect(key),
              child: PixelIcon(key, size: 28),
            ),
        ],
      ),
    );
  }
}
