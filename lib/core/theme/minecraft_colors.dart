import 'package:flutter/material.dart';

/// The Minecraft palette, ported from the designer mock, exposed as a
/// [ThemeExtension] so widgets read colors via
/// `Theme.of(context).extension<MinecraftColors>()!`.
@immutable
class MinecraftColors extends ThemeExtension<MinecraftColors> {
  const MinecraftColors({
    required this.voidDark,
    required this.obsidian,
    required this.obsidianLight,
    required this.obsidianDeep,
    required this.grassGreen,
    required this.dirtBrown,
    required this.stoneMid,
    required this.stoneDark,
    required this.stoneLight,
    required this.plankTan,
    required this.plankDark,
    required this.plankLight,
    required this.redstone,
    required this.diamond,
    required this.gold,
    required this.xpGreen,
    required this.white,
    required this.slotInner,
    required this.slotBorder,
    required this.chestBlack,
    required this.chestMid,
    required this.chestLight,
    required this.chestDark,
    required this.headerBar,
  });

  /// The single dark base every screen sits on (scaffold, home, sky).
  final Color voidDark;
  final Color obsidian;
  final Color obsidianLight;

  /// Deep end for surface gradients (darker than obsidian, above voidDark).
  final Color obsidianDeep;
  final Color grassGreen;
  final Color dirtBrown;
  final Color stoneMid;
  final Color stoneDark;
  final Color stoneLight;
  final Color plankTan;
  final Color plankDark;
  final Color plankLight;
  final Color redstone;
  final Color diamond;
  final Color gold;
  final Color xpGreen;
  final Color white;
  final Color slotInner;
  final Color slotBorder;
  final Color chestBlack;
  final Color chestMid;
  final Color chestLight;
  final Color chestDark;
  final Color headerBar;

  /// The default (and only) palette, matching the mock's dark obsidian theme.
  static const MinecraftColors dark = MinecraftColors(
    voidDark: Color(0xFF0B0A10),
    obsidian: Color(0xFF1D1A24),
    obsidianLight: Color(0xFF2E2A38),
    obsidianDeep: Color(0xFF14111B),
    grassGreen: Color(0xFF5B8731),
    dirtBrown: Color(0xFF7B5B3A),
    stoneMid: Color(0xFF8C8C8C),
    stoneDark: Color(0xFF5A5A5A),
    stoneLight: Color(0xFFC0C0C0),
    plankTan: Color(0xFFBC8F5A),
    plankDark: Color(0xFF8B6840),
    plankLight: Color(0xFFD4A96E),
    redstone: Color(0xFFD63B2F),
    diamond: Color(0xFF4FD9D9),
    gold: Color(0xFFF5C842),
    xpGreen: Color(0xFF7FDB4A),
    white: Color(0xFFF0F0F0),
    slotInner: Color(0xFF1A1A1A),
    slotBorder: Color(0xFF555555),
    chestBlack: Color(0xFF160E07),
    chestMid: Color(0xFF9A6E42),
    chestLight: Color(0xFFB8895A),
    chestDark: Color(0xFF7A5533),
    headerBar: Color(0xFF26222F),
  );

  /// Lighten a color by [amount] (0-255 per channel), mirroring the mock's
  /// `lighten` helper used to build bevel highlights.
  static Color lighten(Color c, int amount) {
    return Color.fromARGB(
      (c.a * 255.0).round(),
      ((c.r * 255.0).round() + amount).clamp(0, 255),
      ((c.g * 255.0).round() + amount).clamp(0, 255),
      ((c.b * 255.0).round() + amount).clamp(0, 255),
    );
  }

  /// Darken a color by [amount] (0-255 per channel).
  static Color darken(Color c, int amount) => lighten(c, -amount);

  @override
  MinecraftColors copyWith({
    Color? voidDark,
    Color? obsidian,
    Color? obsidianLight,
    Color? obsidianDeep,
    Color? grassGreen,
    Color? dirtBrown,
    Color? stoneMid,
    Color? stoneDark,
    Color? stoneLight,
    Color? plankTan,
    Color? plankDark,
    Color? plankLight,
    Color? redstone,
    Color? diamond,
    Color? gold,
    Color? xpGreen,
    Color? white,
    Color? slotInner,
    Color? slotBorder,
    Color? chestBlack,
    Color? chestMid,
    Color? chestLight,
    Color? chestDark,
    Color? headerBar,
  }) {
    return MinecraftColors(
      voidDark: voidDark ?? this.voidDark,
      obsidian: obsidian ?? this.obsidian,
      obsidianLight: obsidianLight ?? this.obsidianLight,
      obsidianDeep: obsidianDeep ?? this.obsidianDeep,
      grassGreen: grassGreen ?? this.grassGreen,
      dirtBrown: dirtBrown ?? this.dirtBrown,
      stoneMid: stoneMid ?? this.stoneMid,
      stoneDark: stoneDark ?? this.stoneDark,
      stoneLight: stoneLight ?? this.stoneLight,
      plankTan: plankTan ?? this.plankTan,
      plankDark: plankDark ?? this.plankDark,
      plankLight: plankLight ?? this.plankLight,
      redstone: redstone ?? this.redstone,
      diamond: diamond ?? this.diamond,
      gold: gold ?? this.gold,
      xpGreen: xpGreen ?? this.xpGreen,
      white: white ?? this.white,
      slotInner: slotInner ?? this.slotInner,
      slotBorder: slotBorder ?? this.slotBorder,
      chestBlack: chestBlack ?? this.chestBlack,
      chestMid: chestMid ?? this.chestMid,
      chestLight: chestLight ?? this.chestLight,
      chestDark: chestDark ?? this.chestDark,
      headerBar: headerBar ?? this.headerBar,
    );
  }

  @override
  MinecraftColors lerp(ThemeExtension<MinecraftColors>? other, double t) {
    if (other is! MinecraftColors) return this;
    return MinecraftColors(
      voidDark: Color.lerp(voidDark, other.voidDark, t)!,
      obsidian: Color.lerp(obsidian, other.obsidian, t)!,
      obsidianLight: Color.lerp(obsidianLight, other.obsidianLight, t)!,
      obsidianDeep: Color.lerp(obsidianDeep, other.obsidianDeep, t)!,
      grassGreen: Color.lerp(grassGreen, other.grassGreen, t)!,
      dirtBrown: Color.lerp(dirtBrown, other.dirtBrown, t)!,
      stoneMid: Color.lerp(stoneMid, other.stoneMid, t)!,
      stoneDark: Color.lerp(stoneDark, other.stoneDark, t)!,
      stoneLight: Color.lerp(stoneLight, other.stoneLight, t)!,
      plankTan: Color.lerp(plankTan, other.plankTan, t)!,
      plankDark: Color.lerp(plankDark, other.plankDark, t)!,
      plankLight: Color.lerp(plankLight, other.plankLight, t)!,
      redstone: Color.lerp(redstone, other.redstone, t)!,
      diamond: Color.lerp(diamond, other.diamond, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      xpGreen: Color.lerp(xpGreen, other.xpGreen, t)!,
      white: Color.lerp(white, other.white, t)!,
      slotInner: Color.lerp(slotInner, other.slotInner, t)!,
      slotBorder: Color.lerp(slotBorder, other.slotBorder, t)!,
      chestBlack: Color.lerp(chestBlack, other.chestBlack, t)!,
      chestMid: Color.lerp(chestMid, other.chestMid, t)!,
      chestLight: Color.lerp(chestLight, other.chestLight, t)!,
      chestDark: Color.lerp(chestDark, other.chestDark, t)!,
      headerBar: Color.lerp(headerBar, other.headerBar, t)!,
    );
  }
}
