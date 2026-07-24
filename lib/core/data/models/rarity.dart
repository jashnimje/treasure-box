import 'package:flutter/material.dart';

import '../../theme/minecraft_colors.dart';

/// Item rarity, styled after Minecraft tooltip name colors.
///
/// Stored in the database as [Rarity.name] (a string) so rows stay readable
/// and reordering this enum never corrupts existing data.
enum Rarity {
  common('Common'),
  uncommon('Uncommon'),
  rare('Rare'),
  epic('Epic'),
  legendary('Legendary');

  const Rarity(this.label);

  /// Human-facing label shown in the UI.
  final String label;

  /// Parse a stored string back into a [Rarity], defaulting to [common].
  static Rarity fromName(String? value) {
    return Rarity.values.firstWhere(
      (r) => r.name == value,
      orElse: () => Rarity.common,
    );
  }

  /// The tooltip-name color, matching the vanilla rarity formatting codes:
  /// common white, uncommon yellow, rare aqua, epic light purple.
  /// Legendary is this app's own tier, in gold.
  Color color(MinecraftColors mc) {
    switch (this) {
      case Rarity.common:
        return const Color(0xFFFFFFFF);
      case Rarity.uncommon:
        return const Color(0xFFFFFF55);
      case Rarity.rare:
        return const Color(0xFF55FFFF);
      case Rarity.epic:
        return const Color(0xFFFF55FF);
      case Rarity.legendary:
        return mc.gold;
    }
  }
}
