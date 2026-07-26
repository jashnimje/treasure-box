import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/widgets/minecraft_chest.dart';

/// **Validates: Requirements 2.2**
///
/// Property 1: Skin key produces distinct color sets.
/// For any two distinct valid skin keys ('oak', 'trapped', 'ender', 'christmas'),
/// ChestSkin.fromKey returns instances with at least one differing color field.
/// Also: null, empty, and unknown keys resolve to oak.
void main() {
  group('ChestSkin.fromKey — Property 1: Distinct color sets', () {
    const validKeys = ['oak', 'trapped', 'ender', 'christmas'];

    /// Extracts all color fields from a ChestSkin for comparison.
    List<Color> colorsOf(ChestSkin skin) => [
          skin.front,
          skin.top,
          skin.side,
          skin.plank,
          skin.outline,
          skin.iron,
          skin.ironHi,
          skin.ironDark,
          skin.knob,
          skin.keyhole,
        ];

    test('every pair of distinct valid keys has at least one differing color',
        () {
      for (var i = 0; i < validKeys.length; i++) {
        for (var j = i + 1; j < validKeys.length; j++) {
          final skinA = ChestSkin.fromKey(validKeys[i]);
          final skinB = ChestSkin.fromKey(validKeys[j]);
          final colorsA = colorsOf(skinA);
          final colorsB = colorsOf(skinB);

          final hasDifference =
              List.generate(colorsA.length, (k) => colorsA[k] != colorsB[k])
                  .any((diff) => diff);

          expect(hasDifference, isTrue,
              reason:
                  'Skins "${validKeys[i]}" and "${validKeys[j]}" must differ '
                  'in at least one color field');
        }
      }
    });

    test('null key resolves to oak', () {
      final skin = ChestSkin.fromKey(null);
      final oak = ChestSkin.fromKey('oak');
      expect(colorsOf(skin), equals(colorsOf(oak)));
    });

    test('empty string resolves to oak', () {
      final skin = ChestSkin.fromKey('');
      final oak = ChestSkin.fromKey('oak');
      expect(colorsOf(skin), equals(colorsOf(oak)));
    });

    test('unknown keys resolve to oak', () {
      const unknownKeys = [
        'jungle',
        'acacia',
        'SPRUCE',
        'OAK',
        ' oak',
        'dark_oak',
        '123',
        'null',
      ];
      final oak = ChestSkin.fromKey('oak');
      final oakColors = colorsOf(oak);

      for (final key in unknownKeys) {
        final skin = ChestSkin.fromKey(key);
        expect(colorsOf(skin), equals(oakColors),
            reason: 'Unknown key "$key" should resolve to oak');
      }
    });

    test('fromKey is deterministic — same key always returns same colors', () {
      for (final key in validKeys) {
        final skin1 = ChestSkin.fromKey(key);
        final skin2 = ChestSkin.fromKey(key);
        expect(colorsOf(skin1), equals(colorsOf(skin2)),
            reason: 'ChestSkin.fromKey("$key") must be deterministic');
      }
    });

    test('each valid key returns a non-null skin with all color fields set',
        () {
      for (final key in validKeys) {
        final skin = ChestSkin.fromKey(key);
        for (final color in colorsOf(skin)) {
          expect(color, isNotNull,
              reason: 'All color fields of skin "$key" must be non-null');
          expect(color.a, greaterThan(0.0),
              reason:
                  'Skin "$key" should have opaque colors (alpha > 0)');
        }
      }
    });
  });
}
