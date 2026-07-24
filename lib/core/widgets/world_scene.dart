import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/mine_block.dart';

/// A mineable ore embedded in the cave wall - the home screen easter egg.
/// Positions are deterministic per scene width so hit-testing and painting
/// agree without shared state. Hardness/points come from the shared
/// [OreKind] rulebook so wall mining plays by the same rules everywhere.
class CaveOre {
  const CaveOre({
    required this.worldX,
    required this.y,
    required this.kind,
  });

  final double worldX;
  final double y;

  final OreKind kind;

  /// One wall grid cell - ore blocks ARE wall blocks (same size, same
  /// grid), just ones with ore in them that happen to be breakable.
  static const double blockSize = 44.0;

  /// The deterministic ore field for a panorama of [totalWidth]. Ore blocks
  /// snap to the wall's running-bond grid (cell + half-offset rows), spaced
  /// so a couple are visible per screen. Rarity follows value: mostly
  /// iron/redstone/coal, gold uncommon, diamond rare.
  static List<CaveOre> field(double totalWidth, double floorY) {
    final ores = <CaveOre>[];
    const spacing = 260.0;
    final rows = (floorY / blockSize).floor();
    final count = (totalWidth / spacing).floor();
    for (var i = 0; i < count; i++) {
      // Deterministic pseudo-scatter, then snapped to the wall grid.
      final h = (i * 2654435761) & 0x7fffffff;
      final rawX = spacing * i + 40.0 + (h % 120);
      // Keep ores in the visible mid/lower wall band (rows 1..rows-1).
      final row = rows <= 2 ? 1 : 1 + ((h >> 8) % (rows - 1));
      final offset = row.isEven ? 0.0 : blockSize / 2;
      final col = ((rawX + offset) / blockSize).floor();
      final worldX = col * blockSize - offset;
      final y = row * blockSize.toDouble();
      final roll = (h >> 16) % 100;
      final kind = roll < 30
          ? OreKind.iron
          : roll < 55
              ? OreKind.redstone
              : roll < 75
                  ? OreKind.coal
                  : roll < 92
                      ? OreKind.gold
                      : OreKind.diamond;
      ores.add(CaveOre(worldX: worldX, y: y, kind: kind));
    }
    return ores;
  }
}

/// An immersive Minecraft cave painted as a panorama wider than the viewport
/// (default 3x), translated by [cameraX] so only the visible slice is shown.
/// Painted with a CustomPainter so it is crisp and cheap; deterministic (no
/// randomness) so it looks identical every frame.
class WorldScenePanoramicWidget extends StatelessWidget {
  const WorldScenePanoramicWidget({
    super.key,
    required this.cameraX,
    required this.viewportWidth,
    this.totalWidth,
    this.torches = true,
    this.oreCracks = const {},
    this.minedOres = const {},
    this.child,
  });

  /// Current horizontal camera offset in logical pixels.
  final double cameraX;

  /// The width of the visible viewport (typically MediaQuery size.width).
  final double viewportWidth;

  /// Total panoramic scene width. Defaults to 3 * [viewportWidth] if null.
  final double? totalWidth;

  /// Whether to paint torches on the wall.
  final bool torches;

  /// Crack stage per ore index (1..2); mined ores live in [minedOres].
  final Map<int, int> oreCracks;

  /// Indexes of ores already mined out (leave a dark hole).
  final Set<int> minedOres;

  /// Optional child widget rendered above the scene.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: WorldScenePanoramic(
            cameraX: cameraX,
            viewportWidth: viewportWidth,
            totalWidth: totalWidth,
            torches: torches,
            oreCracks: oreCracks,
            minedOres: minedOres,
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

/// A [CustomPainter] that renders a panoramic Minecraft room wider than the
/// viewport. Accepts [cameraX] to offset the paint origin so only the visible
/// slice is painted. Ore flecks and mortar bevels use deterministic hashes.
///
/// Vignette and warm glow are viewport-relative: painted after the camera
/// translate is restored so they stay fixed on screen.
class WorldScenePanoramic extends CustomPainter {
  const WorldScenePanoramic({
    required this.cameraX,
    required this.viewportWidth,
    this.torches = true,
    this.totalWidth,
    this.oreCracks = const {},
    this.minedOres = const {},
  });

  /// Current horizontal offset (pixels scrolled to the right).
  final double cameraX;

  /// Width of the visible viewport.
  final double viewportWidth;

  /// Whether to render torches.
  final bool torches;

  /// If null, defaults to 3 * [viewportWidth].
  final double? totalWidth;

  /// Crack stage per ore index; mined ores are holes.
  final Map<int, int> oreCracks;
  final Set<int> minedOres;

  // Stone wall shades (same as _WorldPainter for consistency).
  static const _stone = [
    Color(0xFF4C4C4C),
    Color(0xFF545454),
    Color(0xFF444444),
    Color(0xFF585858),
    Color(0xFF3E3E3E),
    Color(0xFF4F4F4F),
  ];
  static const _stoneEdge = Color(0xFF2E2E2E);
  // Cave floor: slate tones a touch darker than the wall - visible texture,
  // reads as ground under the torchlight.
  static const _floorStone = [
    Color(0xFF46464C),
    Color(0xFF4E4E55),
    Color(0xFF404047),
    Color(0xFF4A4A50),
  ];
  static const _floorEdge = Color(0xFF2A2A2F);
  static const _floorHi = Color(0xFF5E5E66);
  static const _torch = Color(0xFFFF9A2E);
  static const _torchTip = Color(0xFFFFD24A);

  /// Computes the effective total panoramic width.
  double get _sceneWidth =>
      math.max(3 * viewportWidth, totalWidth ?? 3 * viewportWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    final sceneW = _sceneWidth;
    final floorY = size.height * 0.62;

    // --- Sky/air gradient (viewport-relative, painted before translate) ---
    p.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0A0A12), Color(0xFF15151C), Color(0xFF1C1610)],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, p);
    p.shader = null;

    // --- Apply camera translation ---
    canvas.save();
    canvas.translate(-cameraX, 0);

    // --- Stone-brick wall across the full panoramic width ---
    const cell = 44.0;
    final cols = (sceneW / cell).ceil() + 1;
    final rows = (floorY / cell).ceil() + 1;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        // Running-bond offset every other row.
        final offset = (r.isEven ? 0.0 : cell / 2);
        final x = c * cell - offset;
        final y = r * cell;

        // Skip columns that are entirely outside the viewport for perf.
        if (x + cell < cameraX - cell || x > cameraX + viewportWidth + cell) {
          continue;
        }

        final shade =
            _stone[((r * 5 + c * 3) ^ (r + c)).abs() % _stone.length];
        p.color = shade;
        canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), p);
        // Rough cobble texel noise inside the block (like the real cave
        // stone texture) - no clean mortar grid, just broken rock.
        const texels = 5;
        const t = cell / texels;
        for (var i = 0; i < texels; i++) {
          for (var j = 0; j < texels; j++) {
            final h = (((r * 31 + c) * 7 + i) * 13 + j) * 2654435761;
            final m = (h >> 8) % 9;
            if (m > 2) continue; // most texels keep the base shade
            final f = m == 0 ? 0.86 : (m == 1 ? 1.10 : 0.94);
            p.color = Color.fromARGB(
              255,
              (shade.r * 255 * f).round().clamp(0, 255),
              (shade.g * 255 * f).round().clamp(0, 255),
              (shade.b * 255 * f).round().clamp(0, 255),
            );
            canvas.drawRect(Rect.fromLTWH(x + i * t, y + j * t, t, t), p);
          }
        }
        // Soft crack edge on bottom/right only (broken rock, not tiles).
        p.color = _stoneEdge.withValues(alpha: 0.7);
        canvas.drawRect(Rect.fromLTWH(x, y + cell - 1.5, cell, 1.5), p);
        canvas.drawRect(Rect.fromLTWH(x + cell - 1.5, y, 1.5, cell), p);
      }
    }

    // --- Base cave darkness: the whole wall falls into shadow (heavier at
    // the ceiling). The torches painted later punch ADDITIVE light pools
    // through this, so they are visibly what lights the cave. ---
    p.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withValues(alpha: 0.62),
        Colors.black.withValues(alpha: 0.34),
        Colors.black.withValues(alpha: 0.22),
        Colors.black.withValues(alpha: 0.34),
      ],
      stops: const [0.0, 0.30, 0.55, 1.0],
    ).createShader(Rect.fromLTWH(cameraX, 0, viewportWidth, floorY));
    canvas.drawRect(Rect.fromLTWH(cameraX, 0, viewportWidth, floorY), p);
    p.shader = null;

    // --- Dark seam where wall meets floor ---
    p.color = const Color(0xFF000000).withValues(alpha: 0.45);
    canvas.drawRect(Rect.fromLTWH(0, floorY - 6, sceneW, 8), p);
    // Thin lit edge at the very base of the wall (light catching the skirt).
    p.color = const Color(0xFF5A5A60).withValues(alpha: 0.35);
    canvas.drawRect(Rect.fromLTWH(0, floorY - 8, sceneW, 2), p);

    // --- Cave stone floor as a TRUE ground plane: block tiles drawn as
    // parallelograms skewed along the SAME depth axis the chest uses
    // (cabinet projection, back recedes up-and-right). Rows foreshorten
    // toward the wall; nearer rows are deeper and darker. Because floor and
    // chest share one projection, the chest visibly stands ON this ground.
    final floorH = size.height - floorY;
    // Screen-x shift per screen-y of depth (chest painter: kx/ky = cot).
    const skewPerY = 0.55;
    const floorRows = 5;
    // Rows grow toward the viewer (near rows deeper).
    double rowY(int r) => floorY + floorH * math.pow(r / floorRows, 1.5);
    for (var r = 0; r < floorRows; r++) {
      final y0 = rowY(r); // far edge of this row (toward the wall)
      final y1 = rowY(r + 1); // near edge
      // Skew: a point farther back sits further right, like the chest's z.
      final skew0 = (size.height - y0) * skewPerY;
      final skew1 = (size.height - y1) * skewPerY;
      final tileW = 58.0 * (0.75 + 0.9 * (r / floorRows));
      final n = ((sceneW + skew0) / tileW).ceil() + 2;
      for (var c = 0; c < n; c++) {
        final x = c * tileW - tileW - skew0;
        if (x + tileW + skew0 < cameraX - tileW ||
            x > cameraX + viewportWidth + tileW) {
          continue;
        }
        // Parallelogram tile: top edge shifted right by (skew0 - skew1)
        // relative to its bottom edge.
        final path = Path()
          ..moveTo(x + skew0, y0)
          ..lineTo(x + tileW + skew0, y0)
          ..lineTo(x + tileW + skew1, y1)
          ..lineTo(x + skew1, y1)
          ..close();
        final base =
            _floorStone[((r * 3 + c * 7) ^ (r + c)).abs() % _floorStone.length];
        p.color = base;
        canvas.drawPath(path, p);
        // Cobble texel noise inside the tile (same rough rock as the wall),
        // texels skewed with the tile so the pattern lies on the ground.
        const ftex = 4;
        final rowH = y1 - y0;
        for (var i = 0; i < ftex; i++) {
          for (var j = 0; j < ftex; j++) {
            final h = (((r * 47 + c) * 7 + i) * 13 + j) * 2654435761;
            final m = (h >> 8) % 9;
            if (m > 2) continue;
            final f = m == 0 ? 0.86 : (m == 1 ? 1.12 : 0.94);
            p.color = Color.fromARGB(
              255,
              (base.r * 255 * f).round().clamp(0, 255),
              (base.g * 255 * f).round().clamp(0, 255),
              (base.b * 255 * f).round().clamp(0, 255),
            );
            final ty0 = y0 + rowH * j / ftex;
            final ty1 = y0 + rowH * (j + 1) / ftex;
            final s0 = (size.height - ty0) * skewPerY;
            final s1 = (size.height - ty1) * skewPerY;
            final tx = x + tileW * i / ftex;
            final tw = tileW / ftex;
            final texel = Path()
              ..moveTo(tx + s0, ty0)
              ..lineTo(tx + tw + s0, ty0)
              ..lineTo(tx + tw + s1, ty1)
              ..lineTo(tx + s1, ty1)
              ..close();
            canvas.drawPath(texel, p);
          }
        }
        // Depth-axis seam on the right edge (slants like the chest side).
        p.color = _floorEdge;
        final seam = Path()
          ..moveTo(x + tileW + skew0, y0)
          ..lineTo(x + tileW + skew0 + 1.5, y0)
          ..lineTo(x + tileW + skew1 + 1.5, y1)
          ..lineTo(x + tileW + skew1, y1)
          ..close();
        canvas.drawPath(seam, p);
        // Row seams: lit far edge, dark near edge.
        p.color = _floorHi;
        canvas.drawRect(
            Rect.fromLTWH(x + skew0 - tileW, y0, tileW * 3, 1.5), p);
        // Rows fade toward the camera, keeping the wall strip lit so
        // chests read as standing right on it.
        final dim = 0.05 + 0.28 * (r / floorRows);
        p.color = Colors.black.withValues(alpha: dim);
        canvas.drawPath(path, p);
      }
    }

    // --- Stalactites hanging from the cave ceiling ---
    const stalSpacing = 170.0;
    final stalCount = (sceneW / stalSpacing).floor();
    for (var i = 0; i < stalCount; i++) {
      final h = (i * 40503) & 0x7fffffff;
      final sx = stalSpacing * i + (h % 90);
      if (sx < cameraX - 60 || sx > cameraX + viewportWidth + 60) continue;
      final len = 16.0 + (h % 5) * 9.0;
      final w0 = 12.0 + (h % 3) * 5.0;
      p.color = const Color(0xFF2A2A2E);
      canvas.drawRect(Rect.fromLTWH(sx, 0, w0, len * 0.55), p);
      p.color = const Color(0xFF232327);
      canvas.drawRect(
          Rect.fromLTWH(sx + w0 * 0.25, len * 0.55, w0 * 0.5, len * 0.3), p);
      canvas.drawRect(
          Rect.fromLTWH(sx + w0 * 0.375, len * 0.85, w0 * 0.25, len * 0.15),
          p);
    }

    // --- Mineable ores embedded in the wall (the easter egg) ---
    final ores = CaveOre.field(sceneW, floorY);
    for (var i = 0; i < ores.length; i++) {
      final ore = ores[i];
      if (ore.worldX < cameraX - 60 ||
          ore.worldX > cameraX + viewportWidth + 60) {
        continue;
      }
      _paintOre(canvas, ore, i);
    }

    // --- Torches evenly spaced across the panorama (~300lp apart) ---
    if (torches) {
      const torchSpacing = 300.0;
      final torchCount = (sceneW / torchSpacing).floor();
      for (var i = 0; i < torchCount; i++) {
        final tx = torchSpacing * 0.5 + i * torchSpacing;
        // Only paint torches near the visible viewport.
        if (tx > cameraX - 100 && tx < cameraX + viewportWidth + 100) {
          // Slight vertical variation per torch (deterministic).
          final ty = size.height * 0.22 + (i % 3) * 8.0;
          _paintTorch(canvas, Offset(tx, ty));
        }
      }
    }

    // --- Restore canvas (undo camera translate) ---
    canvas.restore();

    // --- Viewport-relative effects (painted after translate restoration) ---
    // (No generic center glow: light comes from the torches and the chest.)

    // Vignette for moody cave feel.
    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 0.95,
        colors: [
          Colors.black.withValues(alpha: 0.10),
          Colors.black.withValues(alpha: 0.28),
          Colors.black.withValues(alpha: 0.82),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }

  /// Paints one mineable ore block: an ore-flecked stone block that shows
  /// crack stages as it is tapped and a dark hole once mined.
  void _paintOre(Canvas canvas, CaveOre ore, int index) {
    final p = Paint()..isAntiAlias = false;
    const s = CaveOre.blockSize;
    final rect = Rect.fromLTWH(ore.worldX, ore.y, s, s);

    if (minedOres.contains(index)) {
      // Mined out: a dark cavity with a faint inner edge.
      p.color = const Color(0xFF141416);
      canvas.drawRect(rect, p);
      p.color = const Color(0xFF232327);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, s, 3), p);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, 3, s), p);
      return;
    }

    // Same stone as the wall (an ore block IS a wall block), with the same
    // cobble texel noise - only the ore flecks give it away.
    final base = _stone[(index * 5).abs() % _stone.length];
    p.color = base;
    canvas.drawRect(rect, p);
    const texels = 5;
    const t = s / texels;
    for (var i = 0; i < texels; i++) {
      for (var j = 0; j < texels; j++) {
        final h = (((index * 31 + i) * 7 + j) * 13) * 2654435761;
        final m = (h >> 8) % 9;
        if (m > 2) continue;
        final f = m == 0 ? 0.86 : (m == 1 ? 1.10 : 0.94);
        p.color = Color.fromARGB(
          255,
          (base.r * 255 * f).round().clamp(0, 255),
          (base.g * 255 * f).round().clamp(0, 255),
          (base.b * 255 * f).round().clamp(0, 255),
        );
        canvas.drawRect(
            Rect.fromLTWH(rect.left + i * t, rect.top + j * t, t, t), p);
      }
    }
    p.color = _stoneEdge.withValues(alpha: 0.7);
    canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - 1.5, s, 1.5), p);
    canvas.drawRect(Rect.fromLTWH(rect.right - 1.5, rect.top, 1.5, s), p);

    // Ore flecks in the vanilla 4-blob pattern, colored by kind.
    p.color = ore.kind.color;
    canvas.drawRect(Rect.fromLTWH(rect.left + 8, rect.top + 8, 9, 9), p);
    canvas.drawRect(Rect.fromLTWH(rect.left + 26, rect.top + 12, 9, 9), p);
    canvas.drawRect(Rect.fromLTWH(rect.left + 12, rect.top + 26, 9, 9), p);
    canvas.drawRect(Rect.fromLTWH(rect.left + 28, rect.top + 28, 7, 7), p);

    // Crack overlay, scaled to the ore's hardness so a diamond visibly
    // takes more hits: light cracks for the first stage, dense near break.
    final stage = oreCracks[index] ?? 0;
    if (stage > 0) {
      p.color = Colors.black.withValues(alpha: 0.55);
      canvas.drawRect(Rect.fromLTWH(rect.left + 6, rect.top + 4, 2, 16), p);
      canvas.drawRect(Rect.fromLTWH(rect.left + 8, rect.top + 18, 12, 2), p);
      canvas.drawRect(Rect.fromLTWH(rect.left + 30, rect.top + 8, 2, 14), p);
      // Dense cracks when one tap from breaking.
      if (stage >= ore.kind.hardness - 1 && ore.kind.hardness > 1) {
        canvas.drawRect(
            Rect.fromLTWH(rect.left + 18, rect.top + 24, 2, 16), p);
        canvas.drawRect(
            Rect.fromLTWH(rect.left + 22, rect.top + 34, 14, 2), p);
        canvas.drawRect(Rect.fromLTWH(rect.left + 4, rect.top + 30, 10, 2), p);
        canvas.drawRect(Rect.fromLTWH(rect.left + 36, rect.top + 20, 2, 12), p);
      }
    }
  }

  void _paintTorch(Canvas canvas, Offset base) {
    final p = Paint()..isAntiAlias = false;
    // THE light source of the cave: a big additive pool that genuinely
    // lights the wall around it (the wall's own gradient darkens everything
    // else, so brightness visibly comes FROM the torches).
    p.blendMode = BlendMode.plus;
    p.shader = RadialGradient(
      colors: [
        _torch.withValues(alpha: 0.30),
        _torch.withValues(alpha: 0.12),
        const Color(0x00000000),
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromCircle(center: base, radius: 180));
    canvas.drawCircle(base, 180, p);
    // Hot core right at the flame.
    p.shader = RadialGradient(
      colors: [
        _torchTip.withValues(alpha: 0.5),
        const Color(0x00000000),
      ],
    ).createShader(Rect.fromCircle(center: base, radius: 44));
    canvas.drawCircle(base, 44, p);
    p.shader = null;
    p.blendMode = BlendMode.srcOver;

    // Minecraft torch at block scale: a chunky stick angled off the wall
    // with a square coal head and pixel flame.
    // Stick: two stacked segments to fake the diagonal wall mount.
    p.color = const Color(0xFF5A3D20); // dark handle wood
    canvas.drawRect(Rect.fromLTWH(base.dx - 4, base.dy + 14, 8, 14), p);
    p.color = const Color(0xFF7A5530); // lit side of the stick
    canvas.drawRect(Rect.fromLTWH(base.dx - 4, base.dy - 2, 8, 18), p);
    canvas.drawRect(Rect.fromLTWH(base.dx - 1, base.dy - 2, 5, 18), p);
    // Coal head.
    p.color = const Color(0xFF3A2A18);
    canvas.drawRect(Rect.fromLTWH(base.dx - 6, base.dy - 10, 12, 10), p);
    // Flame: bright block with a hotter tip, like the game's pixel flame.
    p.color = _torch;
    canvas.drawRect(Rect.fromLTWH(base.dx - 7, base.dy - 22, 14, 14), p);
    p.color = _torchTip;
    canvas.drawRect(Rect.fromLTWH(base.dx - 4, base.dy - 26, 8, 10), p);
    p.color = const Color(0xFFFFF2B0); // white-hot center
    canvas.drawRect(Rect.fromLTWH(base.dx - 2, base.dy - 20, 4, 6), p);
  }

  @override
  bool shouldRepaint(covariant WorldScenePanoramic oldDelegate) =>
      oldDelegate.cameraX != cameraX ||
      oldDelegate.viewportWidth != viewportWidth ||
      oldDelegate.torches != torches ||
      oldDelegate.totalWidth != totalWidth ||
      oldDelegate.oreCracks != oreCracks ||
      oldDelegate.minedOres != minedOres;
}

