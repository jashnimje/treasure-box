import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'performance_throttle.dart';

// ---------------------------------------------------------------------------
// Particle types
// ---------------------------------------------------------------------------

/// The types of ambient particles the engine can spawn.
enum ParticleType {
  dust,
  torchSpark,
  ember,
  xpOrb,
  batShadow,
  blockBreak,
}

// ---------------------------------------------------------------------------
// Particle data class
// ---------------------------------------------------------------------------

/// A single particle's mutable state. Updated each tick by the engine.
class Particle {
  Particle({
    required this.dx,
    required this.dy,
    required this.vx,
    required this.vy,
    required this.alpha,
    required this.lifetime,
    required this.type,
    required this.color,
    required this.size,
  });

  double dx;
  double dy;
  double vx;
  double vy;
  double alpha;
  final double lifetime;
  double age = 0;
  final ParticleType type;
  final Color color;
  final double size;

  bool get isDead => age >= lifetime;

  /// Advance the particle by [dt] seconds.
  void update(double dt) {
    age += dt;
    dx += vx * dt;
    dy += vy * dt;

    // Type-specific behavior
    switch (type) {
      case ParticleType.dust:
        // Slight horizontal wander
        vx += (vx > 0 ? -0.5 : 0.5) * dt;
        // Fade linearly
        alpha = ((1.0 - age / lifetime) * alpha).clamp(0.0, 1.0);
        break;
      case ParticleType.torchSpark:
        // Quick fade
        alpha = (1.0 - age / lifetime).clamp(0.0, 1.0);
        break;
      case ParticleType.ember:
        // Pulse alpha using a sine wave
        final pulse = 0.5 + 0.5 * sin(age * 4.0);
        alpha = ((1.0 - age / lifetime) * pulse).clamp(0.0, 1.0);
        break;
      case ParticleType.xpOrb:
        // Float in sine wave horizontally + pulse alpha
        dx += sin(age * 3.0) * 0.3;
        final pulse = 0.6 + 0.4 * sin(age * 5.0);
        alpha = ((1.0 - age / lifetime) * pulse).clamp(0.0, 1.0);
        break;
      case ParticleType.batShadow:
        // Linear motion, constant alpha
        alpha = 0.3;
        break;
      case ParticleType.blockBreak:
        // Gravity + fast fade
        vy += 200 * dt; // gravity pull
        alpha = (1.0 - age / lifetime).clamp(0.0, 1.0);
        break;
    }
  }
}

// ---------------------------------------------------------------------------
// ParticleContext - data provided by the parent widget
// ---------------------------------------------------------------------------

/// Provides spatial context so the engine knows where to spawn particles.
class ParticleContext {
  const ParticleContext({
    required this.viewportBounds,
    required this.torchPositions,
    required this.chestPositions,
    required this.chestHasItems,
    required this.cameraX,
  });

  /// The visible rect of the viewport (typically Offset.zero & size).
  final Rect viewportBounds;

  /// World-space x positions of torches, translated to screen space by caller.
  final List<Offset> torchPositions;

  /// Screen-space positions of chests.
  final List<Offset> chestPositions;

  /// Whether each chest has items (parallel to [chestPositions]).
  final List<bool> chestHasItems;

  /// Current camera x offset (for world-space to screen-space math).
  final double cameraX;
}

// ---------------------------------------------------------------------------
// ParticleEngine
// ---------------------------------------------------------------------------

/// Manages the flat list of particles and spawns new ones each tick.
///
/// All randomness is contained here. The painter only iterates and draws.
class ParticleEngine {
  ParticleEngine({int defaultMax = 120, Random? random})
      : _throttle = PerformanceThrottle(defaultMax: defaultMax),
        _random = random ?? Random();

  final PerformanceThrottle _throttle;
  final Random _random;
  final List<Particle> _particles = [];

  double _batTimer = 0;
  double _nextBatInterval = 10;

  /// Read-only access for the painter.
  List<Particle> get particles => _particles;

  /// Current max particle cap (throttle-adjusted).
  int get maxCount => _throttle.currentMax;

  /// Advance simulation by [dt] seconds with the given [ctx].
  void tick(double dt, ParticleContext ctx) {
    _throttle.recordFrame(dt);

    // Update existing particles and remove dead ones.
    _particles.removeWhere((p) => p.isDead);
    for (final p in _particles) {
      p.update(dt);
    }

    // Spawn new particles (respecting cap).
    _spawnDust(dt, ctx);
    _spawnTorchSparks(dt, ctx);
    _spawnEmbers(dt, ctx);
    _spawnXpOrbs(dt, ctx);
    _maybeSpawnBat(dt, ctx);
  }

  /// Spawn a burst of block-break particles from [origin].
  void spawnBlockBreak(Offset origin) {
    final count = 8 + _random.nextInt(5); // 8-12
    const colors = [
      Color(0xFF8C8C8C), // stoneMid
      Color(0xFF4E3620), // dirt brown (custom)
      Color(0xFF5A5A5A), // stoneDark
    ];

    for (int i = 0; i < count && _particles.length < _throttle.currentMax; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 100 + _random.nextDouble() * 150;
      _particles.add(Particle(
        dx: origin.dx,
        dy: origin.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        alpha: 1.0,
        lifetime: 0.3,
        type: ParticleType.blockBreak,
        color: colors[_random.nextInt(colors.length)],
        size: 3,
      ));
    }
  }

  /// Clear all particles (e.g. on dispose).
  void clear() => _particles.clear();

  // -- Spawners ---------------------------------------------------------------

  void _spawnDust(double dt, ParticleContext ctx) {
    // Spawn ~1-2 per second
    if (_random.nextDouble() > dt * 1.5) return;
    if (_particles.length >= _throttle.currentMax) return;

    final bounds = ctx.viewportBounds;
    _particles.add(Particle(
      dx: bounds.left + _random.nextDouble() * bounds.width,
      dy: bounds.top + _random.nextDouble() * bounds.height,
      vx: (_random.nextDouble() - 0.5) * 8, // slight wander
      vy: 5 + _random.nextDouble() * 10, // slow drift downward
      alpha: 0.2 + _random.nextDouble() * 0.2, // 20-40%
      lifetime: 3 + _random.nextDouble() * 3, // 3-6s
      type: ParticleType.dust,
      color: const Color(0xFFC0C0C0), // stoneLight
      size: 2 + _random.nextDouble() * 2, // 2-4px
    ));
  }

  void _spawnTorchSparks(double dt, ParticleContext ctx) {
    // Spawn ~2-3 per torch per second
    for (final torch in ctx.torchPositions) {
      if (_random.nextDouble() > dt * 2.5) continue;
      if (_particles.length >= _throttle.currentMax) break;

      const colors = [
        Color(0xFFF5C842), // gold
        Color(0xFFFF9A2E), // torch orange
      ];

      _particles.add(Particle(
        dx: torch.dx + (_random.nextDouble() - 0.5) * 6,
        dy: torch.dy,
        vx: (_random.nextDouble() - 0.5) * 20,
        vy: -(80 + _random.nextDouble() * 60), // fast upward (negative vy)
        alpha: 1.0,
        lifetime: 0.4 + _random.nextDouble() * 0.4, // 0.4-0.8s
        type: ParticleType.torchSpark,
        color: colors[_random.nextInt(colors.length)],
        size: 2,
      ));
    }
  }

  void _spawnEmbers(double dt, ParticleContext ctx) {
    // Spawn ~1 per second in lower 30% of viewport
    if (_random.nextDouble() > dt * 1.0) return;
    if (_particles.length >= _throttle.currentMax) return;

    final bounds = ctx.viewportBounds;
    final spawnY = bounds.bottom - _random.nextDouble() * bounds.height * 0.3;

    const colors = [
      Color(0xFFD63B2F), // redstone
      Color(0xFFF5C842), // gold
    ];

    _particles.add(Particle(
      dx: bounds.left + _random.nextDouble() * bounds.width,
      dy: spawnY,
      vx: (_random.nextDouble() - 0.5) * 5,
      vy: -(15 + _random.nextDouble() * 15), // slow rise (negative vy)
      alpha: 0.8,
      lifetime: 1 + _random.nextDouble(), // 1-2s
      type: ParticleType.ember,
      color: colors[_random.nextInt(colors.length)],
      size: 3,
    ));
  }

  void _spawnXpOrbs(double dt, ParticleContext ctx) {
    // Spawn near chests that have items, ~0.5 per second per eligible chest
    for (int i = 0; i < ctx.chestPositions.length; i++) {
      if (i >= ctx.chestHasItems.length || !ctx.chestHasItems[i]) continue;
      if (_random.nextDouble() > dt * 0.5) continue;
      if (_particles.length >= _throttle.currentMax) break;

      final chest = ctx.chestPositions[i];
      _particles.add(Particle(
        dx: chest.dx + (_random.nextDouble() - 0.5) * 20,
        dy: chest.dy - 10,
        vx: 0,
        vy: -(20 + _random.nextDouble() * 15), // float upward
        alpha: 0.9,
        lifetime: 2 + _random.nextDouble() * 2, // 2-4s
        type: ParticleType.xpOrb,
        color: const Color(0xFF7FDB4A), // xpGreen
        size: 4,
      ));
    }
  }

  void _maybeSpawnBat(double dt, ParticleContext ctx) {
    _batTimer += dt;
    if (_batTimer < _nextBatInterval) return;
    if (_particles.length >= _throttle.currentMax) return;

    _batTimer = 0;
    _nextBatInterval = 8 + _random.nextDouble() * 7; // 8-15s

    final bounds = ctx.viewportBounds;
    final spawnY = bounds.top + _random.nextDouble() * bounds.height * 0.2;
    final speed = 60 + _random.nextDouble() * 40; // px/sec
    final transitTime = (bounds.width + 24) / speed;

    _particles.add(Particle(
      dx: bounds.left - 12, // spawn off-screen left
      dy: spawnY,
      vx: speed, // cross horizontally
      vy: 0,
      alpha: 0.3,
      lifetime: transitTime,
      type: ParticleType.batShadow,
      color: const Color(0xFF000000), // black at 30% alpha
      size: 12, // 12x6 treated as width; height is size/2
    ));
  }
}

// ---------------------------------------------------------------------------
// ParticlePainter
// ---------------------------------------------------------------------------

/// Custom painter that iterates the engine's particle list and draws them.
class ParticlePainter extends CustomPainter {
  ParticlePainter({required this.particles});

  final List<Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final p in particles) {
      paint.color = p.color.withValues(alpha: p.alpha.clamp(0.0, 1.0));

      switch (p.type) {
        case ParticleType.dust:
        case ParticleType.torchSpark:
        case ParticleType.blockBreak:
          // Draw as a rect
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(p.dx, p.dy),
              width: p.size,
              height: p.size,
            ),
            paint,
          );
          break;
        case ParticleType.ember:
        case ParticleType.xpOrb:
          // Draw as a circle
          canvas.drawCircle(Offset(p.dx, p.dy), p.size / 2, paint);
          break;
        case ParticleType.batShadow:
          // Draw as a wider rect (12x6)
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(p.dx, p.dy),
              width: p.size,
              height: p.size / 2,
            ),
            paint,
          );
          break;
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

// ---------------------------------------------------------------------------
// ParticleOverlay widget
// ---------------------------------------------------------------------------

/// A widget that drives a [ParticleEngine] via a [Ticker] and renders all
/// particles using [CustomPaint]. No per-particle widget tree.
class ParticleOverlay extends StatefulWidget {
  const ParticleOverlay({
    super.key,
    required this.particleContext,
    this.engine,
  });

  /// Provides spatial data (viewport, torch/chest positions).
  final ParticleContext particleContext;

  /// Optional externally-provided engine (for testing). If null, creates one.
  final ParticleEngine? engine;

  @override
  State<ParticleOverlay> createState() => ParticleOverlayState();
}

class ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late final ParticleEngine _engine;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _engine = widget.engine ?? ParticleEngine();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  /// Fire a block-break burst at [origin] (screen space). Used by the room's
  /// ore-mining easter egg.
  void burstAt(Offset origin) => _engine.spawnBlockBreak(origin);

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    // Clamp to avoid burst spawns on first frame or after resume.
    final clampedDt = dt.clamp(0.0, 0.05);
    _engine.tick(clampedDt, widget.particleContext);
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.stop();
    _engine.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(particles: _engine.particles),
      size: Size.infinite,
    );
  }
}
