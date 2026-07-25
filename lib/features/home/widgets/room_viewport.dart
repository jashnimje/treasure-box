import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/data/models/box.dart';
import '../../../core/widgets/particle_overlay.dart';
import '../../../core/widgets/world_scene.dart';
import '../room_camera_controller.dart';
import 'chest_layer.dart';

/// Composes the room panoramic scene, chest layer, and particle overlay into a
/// horizontally pannable viewport.
///
/// Tap-vs-pan: both gestures live on the SAME [GestureDetector], so they never
/// fight in the gesture arena - a quick tap (no movement past the touch slop)
/// fires [onTapUp]; a drag fires the pan callbacks. Chest hit-testing happens
/// here in screen space; per-chest detectors nested under a pan detector
/// would lose the gesture arena and swallow taps on web/desktop.
class RoomViewport extends StatefulWidget {
  const RoomViewport({
    super.key,
    required this.boxes,
    required this.onTapChest,
    required this.onTapAdd,
    this.onOreMined,
    this.lidOpenIndex,
    this.lidOpenValue,
    this.focusBoxIndex,
    this.initialBoxIndex,
  });

  /// The list of treasure boxes from the data layer.
  final List<Box> boxes;

  /// Called when a chest is tapped.
  final void Function(int boxIndex) onTapChest;

  /// Called when the ghost add-chest is tapped.
  final VoidCallback onTapAdd;

  /// Called with the points value when a wall ore breaks (for the
  /// persistent tally shown on the home overlay).
  final void Function(int points)? onOreMined;

  /// Which chest to animate lid open (null = none).
  final int? lidOpenIndex;

  /// 0-1 lid open amount for that chest.
  final double? lidOpenValue;

  /// When set, the camera animates to center this box (e.g. NFC resolved it).
  final int? focusBoxIndex;

  /// The box the camera starts ON, with no animation - so returning to the
  /// room from a chest resumes exactly where the user was.
  final int? initialBoxIndex;

  @override
  State<RoomViewport> createState() => RoomViewportState();
}

class RoomViewportState extends State<RoomViewport>
    with TickerProviderStateMixin {
  RoomCameraController? _camera;
  late AnimationController _idleBob;

  /// Easter-egg mining state: crack stage per ore index, mined-out ores, and
  /// a session points tally shown as a quiet toast. Session-scoped on purpose
  /// - the wall "regenerates" next launch, and none of this touches the
  /// inventory. Hardness and points come from the shared [OreKind] rulebook.
  final Map<int, int> _oreCracks = {};
  final Set<int> _minedOres = {};
  int _minedPoints = 0;
  final GlobalKey<ParticleOverlayState> _particleKey = GlobalKey();

  /// Spacing between chests as a fraction of viewport width.
  static const double _chestSpacingFraction = 0.7;

  /// Approximate distance between torches in the panoramic scene.
  static const double _torchSpacing = 300.0;

  /// Chest widget size (kept in sync with ChestLayer for hit testing).
  static const double _chestSize = 190.0;

  @override
  void initState() {
    super.initState();
    _idleBob = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant RoomViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    final focus = widget.focusBoxIndex;
    if (focus != null && focus != oldWidget.focusBoxIndex) {
      _camera?.snapToIndex(focus, this);
    }
  }

  @override
  void dispose() {
    _idleBob.dispose();
    _camera?.dispose();
    super.dispose();
  }

  /// The index of the chest currently nearest the viewport center (no
  /// threshold). -1 when there are no boxes.
  int get nearestBoxIndex {
    final i = _camera?.nearestIndex ?? -1;
    return (i >= 0 && i < widget.boxes.length) ? i : -1;
  }

  /// Computes world-x positions for each chest + the ghost add-chest slot.
  List<double> _computeChestPositions(double viewportWidth) {
    final chestSpacing = viewportWidth * _chestSpacingFraction;
    final positions = <double>[];

    if (widget.boxes.isEmpty) {
      // Zero-boxes case: ghost add-chest at center.
      positions.add(viewportWidth / 2);
    } else {
      for (int i = 0; i < widget.boxes.length; i++) {
        positions.add(chestSpacing * i + viewportWidth / 2);
      }
      // Ghost add-chest at the end.
      positions.add(chestSpacing * widget.boxes.length + viewportWidth / 2);
    }
    return positions;
  }

  /// Computes the total panoramic width based on chest positions.
  double _computeTotalWidth(
      List<double> chestPositions, double viewportWidth) {
    if (chestPositions.isEmpty) return viewportWidth * 3;
    final lastPosition = chestPositions.last;
    return math.max(viewportWidth * 3, lastPosition + viewportWidth * 0.5);
  }

  /// Builds the list of torch screen-space positions for the particle overlay.
  List<Offset> _computeTorchPositions(
      double totalWidth, double cameraX, double viewportHeight) {
    final positions = <Offset>[];
    final torchCount = (totalWidth / _torchSpacing).floor();
    for (int i = 0; i < torchCount; i++) {
      final worldX = _torchSpacing * (i + 0.5);
      final screenX = worldX - cameraX;
      // Torches are roughly at 30% height in the scene.
      positions.add(Offset(screenX, viewportHeight * 0.3));
    }
    return positions;
  }

  /// Builds chest screen-space positions for the particle overlay.
  List<Offset> _computeChestScreenPositions(
    List<double> worldPositions,
    double cameraX,
    double viewportHeight,
  ) {
    return worldPositions
        .take(widget.boxes.length)
        .map((worldX) => Offset(
              worldX - cameraX,
              viewportHeight * 0.55,
            ))
        .toList();
  }

  /// Maps a tap position to a chest slot index (including the trailing ghost
  /// slot), or null when the tap landed on empty room.
  int? _hitSlotIndex(
    Offset local,
    List<double> chestPositions,
    double viewportHeight,
  ) {
    final cameraX = _camera?.offset ?? 0;
    final floorY = viewportHeight * 0.62;
    // Matches ChestLayer geometry: chest sprite + name-chip band.
    final top = floorY - _chestSize * 0.85;
    final bottom = top + _chestSize * 1.05 + 40;
    if (local.dy < top || local.dy > bottom) return null;

    for (int i = 0; i < chestPositions.length; i++) {
      final screenX = chestPositions[i] - cameraX;
      if ((local.dx - screenX).abs() <= _chestSize / 2) return i;
    }
    return null;
  }

  void _handleTapUp(
    TapUpDetails details,
    List<double> chestPositions,
    double totalWidth,
    double viewportHeight,
  ) {
    final slot = _hitSlotIndex(
      details.localPosition,
      chestPositions,
      viewportHeight,
    );
    if (slot != null) {
      if (slot < widget.boxes.length) {
        widget.onTapChest(slot);
      } else {
        widget.onTapAdd();
      }
      return;
    }
    if (_maybeTapTorch(details.localPosition, totalWidth, viewportHeight)) {
      return;
    }
    _maybeMineOre(details.localPosition, totalWidth, viewportHeight);
  }

  /// Fun: tapping a wall torch showers sparks. Matches the painter's torch
  /// placement (spacing, deterministic vertical wobble).
  bool _maybeTapTorch(
      Offset local, double totalWidth, double viewportHeight) {
    final cameraX = _camera?.offset ?? 0;
    final sceneW =
        math.max(3 * (_camera?.viewportWidth ?? totalWidth), totalWidth);
    final torchCount = (sceneW / _torchSpacing).floor();
    for (var i = 0; i < torchCount; i++) {
      final tx = _torchSpacing * 0.5 + i * _torchSpacing;
      final ty = viewportHeight * 0.22 + (i % 3) * 8.0;
      final screen = Offset(tx - cameraX, ty);
      if ((local - screen).distance < 40) {
        _particleKey.currentState?.burstAt(screen);
        return true;
      }
    }
    return false;
  }

  /// Easter egg: taps on a wall ore crack it (hardness taps per [OreKind] -
  /// diamond and gold take 3, most ores 2) then break it with a particle
  /// burst and a quiet points toast. Purely cosmetic fun.
  void _maybeMineOre(
      Offset local, double totalWidth, double viewportHeight) {
    final cameraX = _camera?.offset ?? 0;
    final floorY = viewportHeight * 0.62;
    final ores = CaveOre.field(
        math.max(3 * (_camera?.viewportWidth ?? totalWidth), totalWidth),
        floorY);
    final worldTap = Offset(local.dx + cameraX, local.dy);
    for (var i = 0; i < ores.length; i++) {
      if (_minedOres.contains(i)) continue;
      final rect = Rect.fromLTWH(
          ores[i].worldX, ores[i].y, CaveOre.blockSize, CaveOre.blockSize);
      if (!rect.contains(worldTap)) continue;

      final kind = ores[i].kind;
      setState(() {
        final stage = (_oreCracks[i] ?? 0) + 1;
        if (stage >= kind.hardness) {
          _oreCracks.remove(i);
          _minedOres.add(i);
          _minedPoints += kind.points;
          _particleKey.currentState?.burstAt(local);
          widget.onOreMined?.call(kind.points);
        } else {
          _oreCracks[i] = stage;
        }
      });

      if (_minedOres.contains(i) && mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 1400),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xE0141416),
            content: Text(
              '+${kind.points} ${kind.label}! '
              '($_minedPoints pts this visit)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFF0F0F0),
                  ),
            ),
          ));
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final viewportHeight = constraints.maxHeight;

        final chestPositions = _computeChestPositions(viewportWidth);
        final totalWidth = _computeTotalWidth(chestPositions, viewportWidth);

        // Lazily create or update camera controller when positions change.
        // Passing the width keeps the focused chest centered across
        // rotation/resize.
        if (_camera == null) {
          _camera = RoomCameraController(
            chestPositions: chestPositions,
            viewportWidth: viewportWidth,
          );
          // Start ON the remembered box - no snap animation on return.
          final start = widget.initialBoxIndex;
          if (start != null && start > 0 && start < chestPositions.length) {
            _camera!.jumpToIndex(start);
          }
        } else {
          _camera!.updatePositions(chestPositions,
              viewportWidth: viewportWidth);
        }

        return AnimatedBuilder(
          animation: _camera!,
          builder: (context, _) {
            final cameraX = _camera!.offset;
            final focusedIndex = _camera!.focusedIndex;

            final torchPositions =
                _computeTorchPositions(totalWidth, cameraX, viewportHeight);
            final chestScreenPositions = _computeChestScreenPositions(
              chestPositions,
              cameraX,
              viewportHeight,
            );
            // For now, all boxes are marked as having items.
            final chestHasItems = List.filled(widget.boxes.length, true);

            final particleContext = ParticleContext(
              viewportBounds: Offset.zero & constraints.biggest,
              torchPositions: torchPositions,
              chestPositions: chestScreenPositions,
              chestHasItems: chestHasItems,
              cameraX: cameraX,
            );

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _handleTapUp(
                  details, chestPositions, totalWidth, viewportHeight),
              onPanUpdate: (details) {
                _camera!.pan(details.delta.dx);
              },
              onPanEnd: (_) {
                _camera!.snapToNearest(this);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background panoramic scene.
                  WorldScenePanoramicWidget(
                    cameraX: cameraX,
                    viewportWidth: viewportWidth,
                    totalWidth: totalWidth,
                    oreCracks: Map.of(_oreCracks),
                    minedOres: Set.of(_minedOres),
                  ),
                  // Chest layer (purely visual; taps resolved above).
                  IgnorePointer(
                    child: ChestLayer(
                      boxes: widget.boxes,
                      cameraOffset: cameraX,
                      viewportWidth: viewportWidth,
                      chestPositions: chestPositions,
                      focusedIndex: focusedIndex,
                      idleAnimation: _idleBob,
                      lidOpenIndex: widget.lidOpenIndex,
                      lidOpenValue: widget.lidOpenValue,
                      chestSize: _chestSize,
                    ),
                  ),
                  // Particle overlay.
                  IgnorePointer(
                    child: ParticleOverlay(
                      key: _particleKey,
                      particleContext: particleContext,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
