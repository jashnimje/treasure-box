import 'package:flutter/material.dart';

import 'minecraft_colors.dart';
import 'minecraft_text_styles.dart';

/// Builds the app [ThemeData] with the Minecraft color and text-style
/// extensions attached.
ThemeData buildMinecraftTheme() {
  const colors = MinecraftColors.dark;
  final textStyles = MinecraftTextStyles.standard(colors.white);

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: colors.voidDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.grassGreen,
      brightness: Brightness.dark,
      surface: colors.obsidian,
    ),
  );

  return base.copyWith(
    extensions: [colors, textStyles],
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.diamond,
      selectionColor: colors.diamond.withValues(alpha: 0.3),
      selectionHandleColor: colors.diamond,
    ),
  );
}

/// Ergonomic access to the Minecraft theme extensions from any widget:
/// `context.mc.gold`, `context.mcText.headingPixel`.
extension MinecraftThemeAccess on BuildContext {
  MinecraftColors get mc => Theme.of(this).extension<MinecraftColors>()!;
  MinecraftTextStyles get mcText =>
      Theme.of(this).extension<MinecraftTextStyles>()!;
}
