import 'package:flutter/material.dart';

/// Bundled font families (registered in pubspec assets, not fetched at runtime).
const String _pixelFamily = 'PressStart2P';
const String _readableFamily = 'VT323';

/// Text styles for the Minecraft theme, exposed as a [ThemeExtension].
///
/// The readability fix lives here: Press Start 2P (the blocky pixel font) is
/// used only for short, large text (>=12px); VT323 (a legible pixel font)
/// carries any sentence-length text at >=16px. This replaces the mock's
/// unreadable 5-8px Press Start 2P body copy. Fonts are bundled as assets for
/// offline stability rather than fetched at runtime.
@immutable
class MinecraftTextStyles extends ThemeExtension<MinecraftTextStyles> {
  const MinecraftTextStyles({
    required this.displayPixel,
    required this.headingPixel,
    required this.labelPixel,
    required this.bodyReadable,
    required this.numeric,
  });

  /// Hero item names.
  final TextStyle displayPixel;

  /// Screen / app-bar titles.
  final TextStyle headingPixel;

  /// Field labels and badges (uppercase in use).
  final TextStyle labelPixel;

  /// Notes, hints, descriptions - anything sentence-length.
  final TextStyle bodyReadable;

  /// Quantities and counts.
  final TextStyle numeric;

  factory MinecraftTextStyles.standard(Color defaultColor) {
    return MinecraftTextStyles(
      displayPixel: TextStyle(
        fontFamily: _pixelFamily,
        fontSize: 20,
        color: defaultColor,
        height: 1.4,
        letterSpacing: 0.5,
      ),
      headingPixel: TextStyle(
        fontFamily: _pixelFamily,
        fontSize: 16,
        color: defaultColor,
        height: 1.4,
        letterSpacing: 0.5,
      ),
      labelPixel: TextStyle(
        fontFamily: _pixelFamily,
        fontSize: 12,
        color: defaultColor,
        height: 1.5,
        letterSpacing: 1,
      ),
      bodyReadable: TextStyle(
        fontFamily: _readableFamily,
        fontSize: 18,
        color: defaultColor,
        height: 1.3,
      ),
      numeric: TextStyle(
        fontFamily: _readableFamily,
        fontSize: 20,
        color: defaultColor,
        height: 1.1,
      ),
    );
  }

  @override
  MinecraftTextStyles copyWith({
    TextStyle? displayPixel,
    TextStyle? headingPixel,
    TextStyle? labelPixel,
    TextStyle? bodyReadable,
    TextStyle? numeric,
  }) {
    return MinecraftTextStyles(
      displayPixel: displayPixel ?? this.displayPixel,
      headingPixel: headingPixel ?? this.headingPixel,
      labelPixel: labelPixel ?? this.labelPixel,
      bodyReadable: bodyReadable ?? this.bodyReadable,
      numeric: numeric ?? this.numeric,
    );
  }

  @override
  MinecraftTextStyles lerp(
    ThemeExtension<MinecraftTextStyles>? other,
    double t,
  ) {
    if (other is! MinecraftTextStyles) return this;
    return MinecraftTextStyles(
      displayPixel: TextStyle.lerp(displayPixel, other.displayPixel, t)!,
      headingPixel: TextStyle.lerp(headingPixel, other.headingPixel, t)!,
      labelPixel: TextStyle.lerp(labelPixel, other.labelPixel, t)!,
      bodyReadable: TextStyle.lerp(bodyReadable, other.bodyReadable, t)!,
      numeric: TextStyle.lerp(numeric, other.numeric, t)!,
    );
  }
}
