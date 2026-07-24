import 'dart:ui' show Color;

/// The one mining rulebook: every mineable block in the app (the cave-wall
/// easter egg today, any future game) uses these kinds, hardness values and
/// point awards, so mining feels consistent everywhere. Purely cosmetic fun -
/// nothing here ever touches the real inventory (hard rule).
enum OreKind {
  stone('Stone', 1, 1, Color(0xFF8C8C8C)),
  coal('Coal', 2, 3, Color(0xFF3A3A3A)),
  iron('Iron', 2, 5, Color(0xFFD8AF93)),
  redstone('Redstone', 2, 5, Color(0xFFE04438)),
  gold('Gold', 3, 10, Color(0xFFF5C842)),
  diamond('Diamond', 3, 25, Color(0xFF4FD9D9));

  const OreKind(this.label, this.hardness, this.points, this.color);

  final String label;

  /// Taps to break: rarer ores are harder.
  final int hardness;

  /// Points awarded when broken.
  final int points;

  /// Fleck color painted on the stone block.
  final Color color;
}
