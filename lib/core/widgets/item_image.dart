import 'dart:io';

import 'package:flutter/material.dart';

import '../data/models/item.dart';
import 'pixel_icon.dart';

/// Shows an item's real photo if one is attached, otherwise its pixel icon.
/// Used in list tiles and the detail hero so both stay consistent.
class ItemImage extends StatelessWidget {
  const ItemImage({super.key, required this.item, this.size = 48});

  final Item item;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (item.hasPhoto) {
      final file = File(item.photoPath!);
      if (file.existsSync()) {
        return SizedBox(
          width: size,
          height: size,
          child: Image.file(file, fit: BoxFit.cover),
        );
      }
    }
    return PixelIcon(item.iconKey, size: size * 0.72);
  }
}
