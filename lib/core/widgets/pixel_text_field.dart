import 'package:flutter/material.dart';

import '../theme/minecraft_theme.dart';

/// A recessed slot-styled text input using the readable body font.
class PixelTextField extends StatelessWidget {
  const PixelTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final body = context.mcText.bodyReadable;
    return Container(
      decoration: BoxDecoration(
        color: mc.slotInner,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.6), width: 2),
          left:
              BorderSide(color: Colors.black.withValues(alpha: 0.6), width: 2),
          right: BorderSide(color: mc.stoneDark, width: 2),
          bottom: BorderSide(color: mc.stoneDark, width: 2),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        textInputAction: textInputAction,
        style: body.copyWith(color: mc.white),
        cursorColor: mc.diamond,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: body.copyWith(color: mc.stoneMid),
        ),
      ),
    );
  }
}
