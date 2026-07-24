import 'package:flutter/material.dart';

import '../theme/minecraft_theme.dart';

/// A plank-styled dropdown (the mock's wooden-sign category picker). Shows a
/// bottom sheet of options so it works on every platform.
class WoodenDropdown<T> extends StatelessWidget {
  const WoodenDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  Future<void> _open(BuildContext context) async {
    final mc = context.mc;
    final text = context.mcText;
    final selected = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: mc.plankTan,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              ListTile(
                title: Text(
                  labelOf(item),
                  style: text.bodyReadable.copyWith(
                    color: mc.obsidian,
                    fontWeight:
                        item == value ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                tileColor: item == value ? mc.plankLight : mc.plankTan,
                onTap: () => Navigator.of(ctx).pop(item),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: mc.plankTan,
          border: Border(
            top: BorderSide(color: mc.plankLight, width: 2),
            left: BorderSide(color: mc.plankLight, width: 2),
            right: BorderSide(color: mc.plankDark, width: 2),
            bottom: BorderSide(color: mc.plankDark, width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelOf(value),
              style: context.mcText.bodyReadable.copyWith(color: mc.obsidian),
            ),
            Icon(Icons.arrow_drop_down, color: mc.obsidian),
          ],
        ),
      ),
    );
  }
}
