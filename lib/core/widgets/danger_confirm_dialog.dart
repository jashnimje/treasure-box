import 'package:flutter/material.dart';

import '../theme/minecraft_theme.dart';
import 'pixel_button.dart';
import 'pixel_panel.dart';

/// TNT-red confirm dialog for destructive actions (clear/delete chest).
/// Pops `true` on confirm, `false`/null otherwise.
class DangerConfirmDialog extends StatelessWidget {
  const DangerConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  /// Shows the dialog and resolves to true only on explicit confirm.
  static Future<bool> ask(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => DangerConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
      ),
    );
    return result == true;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: text.labelPixel.copyWith(color: mc.white)),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: text.bodyReadable.copyWith(color: mc.stoneMid)),
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
                    child: Text(confirmLabel,
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
