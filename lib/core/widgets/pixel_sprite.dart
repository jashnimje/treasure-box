import 'package:flutter/material.dart';

/// One rectangular cell of a pixel sprite, in grid units. Ported directly from
/// the mock's SVG `<rect x y width height fill [opacity]>` elements.
class PixelRect {
  const PixelRect(this.x, this.y, this.w, this.h, this.color,
      [this.opacity = 1.0]);

  final double x;
  final double y;
  final double w;
  final double h;
  final Color color;
  final double opacity;
}

/// A pixel sprite: a grid of [cells] drawn on a [gridW] x [gridH] canvas. The
/// painter scales the grid to any render size, so icons stay crisp at 36/48/96.
class PixelSprite {
  const PixelSprite(this.gridW, this.gridH, this.cells);

  final double gridW;
  final double gridH;
  final List<PixelRect> cells;
}

// Palette constants used by the ported sprites (kept local so sprite data is
// self-contained and matches the mock hex values exactly).
const _silver = Color(0xFFC0C0C0);
const _silverLt = Color(0xFFE0E0E0);
const _plankTan = Color(0xFFBC8F5A);
const _plankDark = Color(0xFF8B6840);
const _plankLight = Color(0xFFD4A96E);
const _dirtBrown = Color(0xFF7B5B3A);
const _stoneMid = Color(0xFF8C8C8C);
const _stoneDark = Color(0xFF5A5A5A);
const _stoneLight = Color(0xFFC0C0C0);
const _diamond = Color(0xFF4FD9D9);
const _diamondHi = Color(0xFF8FFFFF);
const _gold = Color(0xFFF5C842);
const _goldHi = Color(0xFFFFE070);
const _goldDk = Color(0xFFB8930A);
const _grassGreen = Color(0xFF5B8731);
const _white = Color(0xFFF0F0F0);
const _redstone = Color(0xFFD63B2F);
const _lockSilver = Color(0xFFD8DCE0);
const _chestMid = Color(0xFF9A6E42);
const _chestLight = Color(0xFFB8895A);
const _chestDark = Color(0xFF7A5533);
const _chestBlack = Color(0xFF160E07);

/// The sprite registry, keyed by `iconKey`. Item icons match the eight the mock
/// offers, plus chest / anvil / nfc glyphs used elsewhere.
const Map<String, PixelSprite> pixelSprites = {
  'sword': PixelSprite(8, 8, [
    PixelRect(3, 0, 2, 1, _silver),
    PixelRect(3, 1, 2, 5, _silverLt),
    PixelRect(1, 4, 6, 1, _plankTan),
    PixelRect(3, 5, 2, 2, _dirtBrown),
    PixelRect(3, 2, 1, 3, Colors.white, 0.3),
  ]),
  'pickaxe': PixelSprite(8, 8, [
    PixelRect(1, 1, 5, 2, _silver),
    PixelRect(1, 1, 2, 3, _silver),
    PixelRect(5, 1, 2, 2, _stoneLight),
    PixelRect(3, 3, 2, 4, _dirtBrown),
  ]),
  'ingot': PixelSprite(8, 8, [
    PixelRect(1, 2, 6, 4, _gold),
    PixelRect(1, 2, 6, 1, _goldHi),
    PixelRect(1, 5, 6, 1, _goldDk),
    PixelRect(2, 3, 1, 2, _goldHi, 0.6),
  ]),
  'gem': PixelSprite(8, 8, [
    PixelRect(2, 1, 4, 1, _diamond),
    PixelRect(1, 2, 6, 3, _diamond),
    PixelRect(2, 5, 4, 1, _diamond),
    PixelRect(3, 6, 2, 1, _diamond),
    PixelRect(2, 2, 2, 2, _diamondHi, 0.5),
  ]),
  'potion': PixelSprite(8, 8, [
    PixelRect(3, 0, 2, 2, _stoneMid),
    PixelRect(2, 2, 4, 1, _stoneLight),
    PixelRect(1, 3, 6, 4, Color(0xFFA030D0)),
    PixelRect(1, 3, 6, 1, Color(0xFFC060FF)),
    PixelRect(2, 4, 1, 2, Color(0xFFE090FF), 0.5),
  ]),
  'book': PixelSprite(8, 8, [
    PixelRect(1, 1, 6, 6, _plankLight),
    PixelRect(1, 1, 1, 6, _plankDark),
    PixelRect(2, 2, 4, 1, _white, 0.7),
    PixelRect(2, 4, 4, 1, _white, 0.7),
    PixelRect(2, 6, 3, 1, _white, 0.7),
  ]),
  'apple': PixelSprite(8, 8, [
    PixelRect(4, 0, 1, 1, _grassGreen),
    PixelRect(2, 1, 4, 1, Color(0xFFD03020)),
    PixelRect(1, 2, 6, 4, Color(0xFFE04030)),
    PixelRect(2, 6, 4, 1, Color(0xFFC03020)),
    PixelRect(2, 2, 2, 2, Color(0xFFFF8070), 0.5),
  ]),
  'tnt': PixelSprite(8, 8, [
    PixelRect(1, 1, 6, 6, _redstone),
    PixelRect(1, 1, 6, 1, Color(0xFFF5F5F5)),
    PixelRect(1, 3, 6, 1, Color(0xFFF5F5F5)),
    PixelRect(1, 5, 6, 1, Color(0xFFF5F5F5)),
    PixelRect(2, 2, 4, 1, _redstone),
    PixelRect(2, 4, 4, 1, _redstone),
    PixelRect(2, 6, 4, 1, _redstone),
    PixelRect(3, 0, 2, 1, _stoneMid),
  ]),
  // Header / nav glyphs.
  'chest': PixelSprite(16, 15, [
    // body
    PixelRect(0, 5, 16, 10, _chestBlack),
    PixelRect(1, 5, 14, 9, _chestMid),
    PixelRect(1, 5, 1, 9, _chestLight),
    PixelRect(14, 5, 1, 9, _chestDark),
    // lid
    PixelRect(0, 0, 16, 5, _chestBlack),
    PixelRect(1, 1, 14, 3, _chestMid),
    PixelRect(1, 1, 14, 1, _chestLight),
    // lock
    PixelRect(7, 3, 2, 3, _lockSilver),
    PixelRect(7.7, 4, 0.7, 1.3, _chestBlack),
  ]),
  'anvil': PixelSprite(14, 11, [
    PixelRect(1, 0, 12, 4, _stoneMid),
    PixelRect(1, 0, 12, 1, _stoneLight),
    PixelRect(1, 3, 12, 1, _stoneDark),
    PixelRect(4, 4, 6, 2, _stoneMid),
    PixelRect(2, 6, 10, 5, _stoneMid),
    PixelRect(2, 6, 10, 1, _stoneLight),
    PixelRect(2, 10, 10, 1, _stoneDark),
  ]),
  'nfc': PixelSprite(8, 8, [
    PixelRect(3, 3, 2, 2, _diamond),
    PixelRect(2, 2, 1, 4, _diamond),
    PixelRect(5, 2, 1, 4, _diamond),
    PixelRect(0, 2, 1, 4, _diamond),
    PixelRect(7, 2, 1, 4, _diamond),
  ]),
};
