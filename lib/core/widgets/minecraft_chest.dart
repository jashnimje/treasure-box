import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Color skin for a [MinecraftChest], providing wood and hardware palette.
///
/// Named constructors expose the four built-in skins. Use [fromKey] to
/// resolve a persisted string key back to a skin instance.
class ChestSkin {
  const ChestSkin({
    required this.front,
    required this.top,
    required this.side,
    required this.plank,
    required this.outline,
    required this.iron,
    required this.ironHi,
    required this.ironDark,
    required this.knob,
    required this.keyhole,
  });

  /// Wood face colors.
  final Color front;
  final Color top;
  final Color side;
  final Color plank;
  final Color outline;

  /// Hardware colors.
  final Color iron;
  final Color ironHi;
  final Color ironDark;
  final Color knob;
  final Color keyhole;

  /// Classic oak chest - tones sampled from the vanilla texture.
  static const oak = ChestSkin(
    front: Color(0xFFA9763F),
    top: Color(0xFFC08C4C),
    side: Color(0xFF8A6234),
    plank: Color(0xFF6E4C26),
    outline: Color(0xFF241A0E),
    iron: Color(0xFF6E6E76),
    ironHi: Color(0xFF9A9AA2),
    ironDark: Color(0xFF44444C),
    knob: Color(0xFFC6C6C6),
    keyhole: Color(0xFF1B1B1B),
  );

  /// Trapped chest: the same wood as the regular chest, given away only by
  /// the red tinge around the latch - true to the vanilla texture.
  static const trapped = ChestSkin(
    front: Color(0xFFA9763F),
    top: Color(0xFFC08C4C),
    side: Color(0xFF8A6234),
    plank: Color(0xFF6E4C26),
    outline: Color(0xFF241A0E),
    iron: Color(0xFF6E6E76),
    ironHi: Color(0xFF9A9AA2),
    ironDark: Color(0xFF44444C),
    knob: Color(0xFFC64C3B),
    keyhole: Color(0xFF5A1410),
  );

  /// Christmas chest: the festive present texture chests wear in December -
  /// red wrap, snow-white lid, green ribbon latch.
  static const christmas = ChestSkin(
    front: Color(0xFFB03A30),
    top: Color(0xFFE8E4DC),
    side: Color(0xFF8E2E26),
    plank: Color(0xFF6E1F1A),
    outline: Color(0xFF2A0C0A),
    iron: Color(0xFF3E7A3E),
    ironHi: Color(0xFF66A866),
    ironDark: Color(0xFF2A5A2A),
    knob: Color(0xFF4FAE4F),
    keyhole: Color(0xFF1E4A1E),
  );

  /// Ender chest: dark teal obsidian body with the green Eye of Ender latch,
  /// matching the vanilla ender chest texture.
  static const ender = ChestSkin(
    front: Color(0xFF2B4640),
    top: Color(0xFF3A5A52),
    side: Color(0xFF1F332E),
    plank: Color(0xFF122019),
    outline: Color(0xFF060D0B),
    iron: Color(0xFF3E5E52),
    ironHi: Color(0xFF5E8A76),
    ironDark: Color(0xFF23382F),
    knob: Color(0xFF7FE070),
    keyhole: Color(0xFF0E3B1E),
  );

  /// Resolves a string key to a [ChestSkin] instance. A `-large` suffix
  /// (the double-chest type) is stripped first: `trapped-large` -> trapped.
  ///
  /// Returns [oak] for null, empty, 'oak', or any unknown key.
  static ChestSkin fromKey(String? key) {
    switch (baseKey(key)) {
      case 'trapped':
        return trapped;
      case 'ender':
        return ender;
      case 'christmas':
        return christmas;
      default:
        return oak;
    }
  }

  /// True when [key] selects the wide double-chest body.
  static bool isLarge(String? key) => (key ?? '').endsWith('-large');

  /// The skin part of a key with any `-large` type suffix removed.
  static String baseKey(String? key) {
    final k = key ?? '';
    return k.endsWith('-large') ? k.substring(0, k.length - 6) : k;
  }

  /// Compose a stored key from a skin and the large flag.
  static String composeKey(String skin, {required bool large}) =>
      large ? '$skin-large' : skin;
}

/// An authentic-looking Minecraft chest in a 3/4 (cabinet) projection: dark
/// frame strips around every face edge, per-pixel plank texture (a
/// deterministic hash, like the real 14x14 texel faces), and the silver
/// latch hanging over the lid seam.
///
/// [lidOpen] (0 closed, 1 fully open) rotates the lid back on its rear-top
/// hinge, revealing the interior with a warm treasure glow. Geometry follows
/// the classic single-chest proportions (14-wide/14-deep footprint, 10 base +
/// 5 lid on a 16 grid), reproduced as an original mesh.
///
/// [skinKey] selects the color palette ('oak', 'trapped', 'ender', 'christmas').
class MinecraftChest extends StatelessWidget {
  const MinecraftChest({
    super.key,
    this.lidOpen = 0,
    this.size = 200,
    this.skinKey = 'oak',
  });

  final double lidOpen;
  final double size;
  final String skinKey;

  @override
  Widget build(BuildContext context) {
    final skin = ChestSkin.fromKey(skinKey);
    // Reserve headroom above the box for the lid to swing into.
    final h = size * 1.05;
    return SizedBox(
      width: size,
      height: h,
      child: CustomPaint(
        size: Size(size, h),
        painter: _ChestPainter(lidOpen, skin, ChestSkin.isLarge(skinKey)),
      ),
    );
  }
}

// Lid-underside and glow colors remain constant across skins.
const _interiorBack = Color(0xFF35240F);
const _gold = Color(0xFFF5C842);
const _goldHi = Color(0xFFFFE888);

class _ChestPainter extends CustomPainter {
  const _ChestPainter(this.lidOpen, this.skin, [this.large = false]);
  final double lidOpen;
  final ChestSkin skin;

  /// The double-chest body: twice as wide (like two chests merged), same
  /// depth and height - the rectangular trunk shape.
  final bool large;

  // Model dimensions (chest units on a 16 grid).
  double get _w => large ? 26 : 14; // width  (x)
  static const double _d = 14; // depth  (z)
  static const double _hb = 10; // base height (y)
  static const double _hl = 5; // lid height  (y)

  // Cabinet projection: back recedes up-and-right.
  static const double _ang = 0.62; // ~35 degrees
  static const double _depthScale = 0.52;

  /// Frame strip thickness in chest units (the dark border in the texture).
  static const double _frame = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Fit the model into the widget with some padding.
    final unit = size.width / (_w + _d * _depthScale * math.cos(_ang) + 2.5);
    final kx = _depthScale * math.cos(_ang) * unit;
    final ky = _depthScale * math.sin(_ang) * unit;

    // Origin: front-bottom-left of the base, placed to center the whole model.
    final modelW = _w * unit + _d * kx;
    final ox = (size.width - modelW) / 2;
    final oy = size.height - 1.5 * unit;

    // Project a model point (x up-right, y up, z depth-back) to screen.
    Offset pr(double x, double y, double z) =>
        Offset(ox + x * unit + z * kx, oy - y * unit - z * ky);

    final fill = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    void quad(Offset a, Offset b, Offset c, Offset d, Color color) {
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy)
        ..lineTo(d.dx, d.dy)
        ..close();
      fill.color = color;
      canvas.drawPath(path, fill);
    }

    // Deterministic texel shade for wood grain: -1, 0 or +1 step.
    int grain(int i, int j) {
      final h = ((i * 73856093) ^ (j * 19349663)) & 0x7fffffff;
      final m = h % 7;
      if (m == 0) return -1;
      if (m == 1) return 1;
      return 0;
    }

    Color shade(Color base, int step) {
      if (step == 0) return base;
      final f = step > 0 ? 1.10 : 0.90;
      int ch(double v) => (v * 255.0 * f).round().clamp(0, 255);
      return Color.fromARGB(255, ch(base.r), ch(base.g), ch(base.b));
    }

    // Paint one textured face given a bilinear point mapper over (u,v) in
    // [0,1]^2: dark frame strips on the border, per-texel grain inside.
    void texturedFace(
      Offset Function(double u, double v) mp,
      Color base, {
      int texels = 14,
      int gSeed = 0,
    }) {
      // Base fill.
      quad(mp(0, 0), mp(1, 0), mp(1, 1), mp(0, 1), base);
      // Grain texels (skip the frame band).
      final f = _frame / _w; // frame fraction of the face
      final step = 1.0 / texels;
      for (var i = 0; i < texels; i++) {
        for (var j = 0; j < texels; j++) {
          final u0 = i * step, v0 = j * step;
          if (u0 < f || u0 + step > 1 - f || v0 < f || v0 + step > 1 - f) {
            continue;
          }
          final g = grain(i + gSeed * 31, j + gSeed * 17);
          if (g == 0) continue;
          quad(
            mp(u0, v0),
            mp(u0 + step, v0),
            mp(u0 + step, v0 + step),
            mp(u0, v0 + step),
            shade(base, g),
          );
        }
      }
      // Dark frame strips around the face border.
      final frame = skin.outline;
      quad(mp(0, 0), mp(1, 0), mp(1, f), mp(0, f), frame);
      quad(mp(0, 1 - f), mp(1, 1 - f), mp(1, 1), mp(0, 1), frame);
      quad(mp(0, 0), mp(f, 0), mp(f, 1), mp(0, 1), frame);
      quad(mp(1 - f, 0), mp(1, 0), mp(1, 1), mp(1 - f, 1), frame);
    }

    // ---------- CONTACT SHADOW (painted FIRST, under everything) ----------
    // Follows the base's bottom footprint so nothing pokes out as a wedge.
    final fl = pr(0, 0, 0);
    final fr = pr(_w, 0, 0);
    final br = pr(_w, 0, _d);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final shadowPath = Path()
      ..moveTo(fl.dx - 3, fl.dy + 2)
      ..lineTo(fr.dx + 3, fr.dy + 2)
      ..lineTo(br.dx + 3, br.dy + 2)
      ..lineTo(fl.dx + (br.dx - fr.dx) - 3, fl.dy + (br.dy - fr.dy) + 2)
      ..close();
    canvas.drawPath(shadowPath, shadow);

    // ---------- BASE ----------
    // Right side face (x = w): u -> z, v -> y.
    texturedFace(
      (u, v) => pr(_w, v * _hb, u * _d),
      skin.side,
      gSeed: 1,
    );

    // Top rim of the base (visible when the lid tilts back).
    texturedFace(
      (u, v) => pr(u * _w, _hb, v * _d),
      skin.top,
      gSeed: 2,
    );

    // ---------- INTERIOR (revealed as the lid opens) ----------
    if (lidOpen > 0.02) {
      // Walls are exactly as thick as the frame strip, and the inner faces
      // are the box's own wood (darkened) - so looking in reads as "inside
      // the box", with no mystery dark gap beside the walls.
      const inset = _frame;
      Color darken(Color c, double f) => Color.fromARGB(
            255,
            (c.r * 255 * f).round().clamp(0, 255),
            (c.g * 255 * f).round().clamp(0, 255),
            (c.b * 255 * f).round().clamp(0, 255),
          );
      final innerBack = darken(skin.side, 0.55);
      final innerSide = darken(skin.side, 0.72);
      final innerFloor = darken(skin.plank, 0.6);

      final iBackL = pr(inset, _hb, _d - inset);
      final iBackR = pr(_w - inset, _hb, _d - inset);
      final iFrontL = pr(inset, _hb, inset);
      final iFrontR = pr(_w - inset, _hb, inset);
      const drop = 3.2;
      final fBackL = pr(inset, _hb - drop, _d - inset);
      final fBackR = pr(_w - inset, _hb - drop, _d - inset);
      final fFrontL = pr(inset, _hb - drop, inset);
      final fFrontR = pr(_w - inset, _hb - drop, inset);

      // The interior is only ever visible THROUGH the opening. Clip to the
      // opening's projected parallelogram so wall/floor quads can never
      // spill past the rim (unclipped, their right portion painted over the
      // outside of the box as a dark wedge - the box has no solid geometry
      // to occlude them).
      final opening = Path()
        ..moveTo(iFrontL.dx, iFrontL.dy)
        ..lineTo(iFrontR.dx, iFrontR.dy)
        ..lineTo(iBackR.dx, iBackR.dy)
        ..lineTo(iBackL.dx, iBackL.dy)
        ..close();
      canvas.save();
      canvas.clipPath(opening);
      // Base shadow across the whole opening (depth), then the surfaces the
      // camera can actually see: back wall, left inner wall, floor.
      fill.color = darken(skin.plank, 0.45);
      canvas.drawPath(opening, fill);
      quad(iBackL, iBackR, fBackR, fBackL, innerBack);
      quad(iFrontL, iBackL, fBackL, fFrontL, innerSide);
      quad(fFrontL, fFrontR, fBackR, fBackL, innerFloor);
      // Warm treasure glow.
      final c = pr(_w / 2, _hb - drop + 1, _d / 2);
      final glow = Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(colors: [
          _gold.withValues(alpha: 0.85 * lidOpen),
          _gold.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: c, radius: 6 * unit));
      canvas.drawCircle(c, 6 * unit, glow);
      if (lidOpen > 0.5) {
        fill.color = _goldHi.withValues(alpha: (lidOpen - 0.5) * 2);
        canvas.drawRect(
            Rect.fromCenter(center: c, width: 2 * unit, height: 1.4 * unit),
            fill);
      }
      canvas.restore(); // undo the opening clip
    }

    // ---------- LID ----------
    // Rotate lid points about the rear-top hinge (y=_hb, z=_d), axis along
    // x - exactly like the vanilla chest: the lid is a thick slab that tips
    // BACK and comes to rest leaning on the base's rear edge (~65 degrees),
    // never flipping over like a thin flap.
    final theta = lidOpen * 1.15; // up to ~66 degrees
    final ct = math.cos(theta);
    final st = math.sin(theta);
    Offset lp(double x, double y, double z) {
      final ry = y - _hb;
      final rz = z - _d;
      final ny = ry * ct - rz * st;
      final nz = ry * st + rz * ct;
      return pr(x, _hb + ny, _d + nz);
    }

    // Backface culling via projected winding: a face mapped over (u,v) keeps
    // one shoelace sign while its outside faces the camera and flips sign
    // when it rotates away. Painting only front-facing quads is what kills
    // the "wrong flap" artifacts on the open lid.
    double winding(Offset Function(double u, double v) mp) {
      final a = mp(0, 0), b = mp(1, 0), c = mp(1, 1), d = mp(0, 1);
      return (b.dx - a.dx) * (b.dy + a.dy) +
          (c.dx - b.dx) * (c.dy + b.dy) +
          (d.dx - c.dx) * (d.dy + c.dy) +
          (a.dx - d.dx) * (a.dy + d.dy);
    }

    // Paint the lid slab back-to-front so it always reads as a solid box.
    // Right side of the lid (trapezoid showing the slab's thickness).
    Offset sideMp(double u, double v) => lp(_w, _hb + v * _hl, u * _d);
    // Underside of the lid: hidden while closed, faces the viewer as dark
    // interior wood once the lid tips back - exactly like the game.
    Offset underMp(double u, double v) => lp(u * _w, _hb, v * _d);
    // Top face of the lid (rotates back; a backface once tipped past the
    // camera - culled by winding, never painted inside-out).
    Offset topMp(double u, double v) => lp(u * _w, _hb + _hl, v * _d);
    // Front face of the lid (carries the latch; tips up and back).
    Offset frontMp(double u, double v) => lp(u * _w, _hb + v * _hl, 0);

    if (winding(sideMp) > 0) texturedFace(sideMp, skin.side, gSeed: 3);
    if (winding(underMp) < 0) texturedFace(underMp, _interiorBack, gSeed: 7);
    if (winding(topMp) > 0) texturedFace(topMp, skin.top, gSeed: 4);
    if (winding(frontMp) > 0) texturedFace(frontMp, skin.front, gSeed: 5);

    // ---------- BASE FRONT FACE (nearest the camera, painted last) ----------
    texturedFace(
      (u, v) => pr(u * _w, v * _hb, 0),
      skin.front,
      gSeed: 6,
    );

    // ---------- LATCH ----------
    // The silver latch is part of the LID: it hangs from the lid's front
    // bottom edge over the seam, so it swings up with the lid - exactly like
    // the vanilla chest.
    final cx = _w / 2;
    const halfW = 1.0;
    const above = 1.6; // how far up the lid front the plate reaches
    const below = 2.2; // how far it hangs below the seam
    quad(
      lp(cx - halfW, _hb + above, 0),
      lp(cx + halfW, _hb + above, 0),
      lp(cx + halfW, _hb - below, 0),
      lp(cx - halfW, _hb - below, 0),
      skin.knob,
    );
    // Latch shading: left highlight, right shadow.
    quad(
      lp(cx - halfW, _hb + above, 0),
      lp(cx - halfW + 0.35, _hb + above, 0),
      lp(cx - halfW + 0.35, _hb - below, 0),
      lp(cx - halfW, _hb - below, 0),
      skin.ironHi,
    );
    quad(
      lp(cx + halfW - 0.35, _hb + above, 0),
      lp(cx + halfW, _hb + above, 0),
      lp(cx + halfW, _hb - below, 0),
      lp(cx + halfW - 0.35, _hb - below, 0),
      skin.ironDark,
    );
    // Keyhole notch.
    quad(
      lp(cx - 0.3, _hb - 0.4, 0),
      lp(cx + 0.3, _hb - 0.4, 0),
      lp(cx + 0.3, _hb - 1.4, 0),
      lp(cx - 0.3, _hb - 1.4, 0),
      skin.keyhole,
    );

  }

  @override
  bool shouldRepaint(covariant _ChestPainter oldDelegate) =>
      oldDelegate.lidOpen != lidOpen ||
      oldDelegate.skin != skin ||
      oldDelegate.large != large;
}

/// A small static closed chest for headers/badges.
class MiniChest extends StatelessWidget {
  const MiniChest({super.key, this.size = 40, this.skinKey = 'oak'});
  final double size;
  final String skinKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: MinecraftChest(size: 100, lidOpen: 0, skinKey: skinKey),
      ),
    );
  }
}
