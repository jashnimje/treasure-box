import 'package:flutter/material.dart';

import '../../../core/theme/minecraft_theme.dart';
import '../../../core/widgets/pixel_icon.dart';

/// The bottom hotbar navigation shared by the inventory / mine / settings tabs.
/// The active tab gets a diamond frame; a grass `+` button sits at the end.
class HotbarNav extends StatelessWidget {
  const HotbarNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.onAdd,
  });

  /// 0 = Chest, 1 = Info.
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF00A060F),
        border: Border(top: BorderSide(color: mc.obsidianLight, width: 3)),
      ),
      // Bottom inset comes from the SafeArea wrapper, not a hardcoded pad.
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      // The grass + sits CENTER stage (the most-used action), tabs flank it.
      child: Row(
        children: [
          _HotTab(
            label: 'Chest',
            iconKey: 'chest',
            active: currentIndex == 0,
            onTap: () => onSelect(0),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 64,
              height: 52,
              color: mc.grassGreen,
              child: Center(
                child: Text(
                  '+',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: mc.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _HotTab(
            label: 'Info',
            iconKey: 'book',
            active: currentIndex == 1,
            onTap: () => onSelect(1),
          ),
        ],
      ),
    );
  }
}

class _HotTab extends StatelessWidget {
  const _HotTab({
    required this.label,
    required this.iconKey,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String iconKey;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: active ? mc.obsidianLight : Colors.transparent,
            border: Border.all(
              color: active ? mc.diamond : mc.obsidianLight,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PixelIcon(
                iconKey,
                size: 20,
                tint: active ? mc.diamond : mc.stoneMid,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: context.mcText.labelPixel.copyWith(
                  fontSize: 9,
                  color: active ? mc.diamond : mc.stoneMid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
