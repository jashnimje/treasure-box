import 'package:flutter/material.dart';

import '../../../core/data/models/item.dart';
import '../../../core/theme/minecraft_theme.dart';
import '../../../core/widgets/pixel_button.dart';
import '../../../core/widgets/pixel_icon.dart';
import '../../../core/widgets/pixel_panel.dart';

/// A TNT-styled confirm dialog for removing an item.
class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({super.key, required this.item});

  final Item item;

  static Future<bool?> show(BuildContext context, Item item) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PixelPanel(
        fill: const Color(0xF0100820),
        borderColor: mc.redstone,
        borderWidth: 4,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PixelIcon('tnt', size: 40),
            const SizedBox(height: 14),
            Text(
              'Remove ${item.name}?',
              textAlign: TextAlign.center,
              style: text.labelPixel.copyWith(color: mc.white),
            ),
            const SizedBox(height: 10),
            Text(
              'This deletes all ${item.qty} from the chest.',
              textAlign: TextAlign.center,
              style: text.bodyReadable.copyWith(color: mc.stoneMid),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: PixelButton(
                    height: 44,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel',
                        style: text.labelPixel.copyWith(color: mc.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PixelButton(
                    height: 44,
                    variant: PixelButtonVariant.redstone,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Remove',
                        style: text.labelPixel.copyWith(color: mc.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
