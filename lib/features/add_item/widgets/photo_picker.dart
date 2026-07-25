import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/minecraft_theme.dart';
import '../../../core/widgets/pixel_slot.dart';

/// Optional real photo for an item. Shows a thumbnail with a remove button, or
/// a "Choose photo" prompt. Camera is offered on mobile; elsewhere it is a file
/// picker (label says "Choose photo").
class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    required this.photoPath,
    required this.onChanged,
  });

  final String? photoPath;
  final ValueChanged<String?> onChanged;

  bool get _mobile =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    final mc = context.mc;
    final style = context.mcText.bodyReadable.copyWith(color: mc.white);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, maxWidth: 1024);
      if (file != null) onChanged(file.path);
    } catch (e) {
      // Surface the failure (denied camera permission, no camera app)
      // instead of silently doing nothing.
      messenger.showSnackBar(SnackBar(
        backgroundColor: mc.redstone,
        content: Text(
          source == ImageSource.camera
              ? 'Camera unavailable - check the app\'s camera permission'
              : 'Could not pick a photo',
          style: style,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    final hasPhoto = photoPath != null &&
        photoPath!.isNotEmpty &&
        !kIsWeb &&
        File(photoPath!).existsSync();

    return Row(
      children: [
        PixelSlot(
          size: 64,
          child: hasPhoto
              ? Image.file(File(photoPath!), fit: BoxFit.cover)
              : Icon(Icons.image_outlined, color: mc.stoneMid),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  if (_mobile)
                    _MiniButton(
                      label: 'Camera',
                      onTap: () => _pick(context, ImageSource.camera),
                    ),
                  _MiniButton(
                    label: _mobile ? 'Gallery' : 'Choose photo',
                    onTap: () => _pick(context, ImageSource.gallery),
                  ),
                  if (hasPhoto)
                    _MiniButton(
                      label: 'Remove',
                      onTap: () => onChanged(null),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Optional real photo',
                style: text.bodyReadable.copyWith(color: mc.stoneDark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: mc.obsidianLight,
          border: Border.all(color: mc.stoneDark, width: 2),
        ),
        child: Text(label,
            style: context.mcText.bodyReadable.copyWith(color: mc.stoneLight)),
      ),
    );
  }
}
