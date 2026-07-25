import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Controls the horizontal camera offset for the room viewport.
///
/// Manages pan gestures (clamped to bounds), snap-to-nearest-chest animations,
/// and focused-chest index calculation. Chest world positions are computed as
/// `chestSpacing * i` and are independent of camera state.
class RoomCameraController extends ChangeNotifier {
  RoomCameraController({
    required List<double> chestPositions,
    required double viewportWidth,
  })  : _chestPositions = chestPositions,
        _viewportWidth = viewportWidth;

  List<double> _chestPositions;
  double _viewportWidth;

  double _offset = 0.0;

  /// The current horizontal camera offset in world coordinates.
  double get offset => _offset;

  /// The list of chest world-x positions (camera-independent).
  List<double> get chestPositions => _chestPositions;

  /// The viewport width used for bounds and focus calculations.
  double get viewportWidth => _viewportWidth;

  /// The minimum camera offset: exactly centers the FIRST chest. Anything
  /// looser and the initial offset (0, which centers the first chest at
  /// viewport/2) sits outside the bounds and gets clamped later - a visible
  /// camera jump on the first rebuild.
  double get minOffset {
    if (_chestPositions.isEmpty) return 0.0;
    return _chestPositions.first - _viewportWidth / 2;
  }

  /// The maximum camera offset: exactly centers the LAST slot (the ghost
  /// add-chest), so every chest can be brought dead-center.
  double get maxOffset {
    if (_chestPositions.isEmpty) return 0.0;
    return _chestPositions.last - _viewportWidth / 2;
  }

  AnimationController? _snapController;

  /// Called on drag update. Subtracts `dx` from offset (so dragging right
  /// moves the camera left, revealing content to the left) and clamps within
  /// bounds.
  void pan(double dx) {
    _cancelSnap();
    if (_chestPositions.isEmpty) return;
    final lo = minOffset;
    final hi = maxOffset;
    if (lo <= hi) {
      _offset = (_offset - dx).clamp(lo, hi);
    } else {
      // Viewport wider than content range: lock to midpoint.
      _offset = (lo + hi) / 2;
    }
    notifyListeners();
  }

  /// Called on drag end. Animates the camera offset to the nearest chest
  /// center over 350ms with an easeOutCubic curve.
  ///
  /// The snap is cancellable: if [pan] is called mid-animation, the animation
  /// stops and the user resumes direct control.
  void snapToNearest(TickerProvider vsync) {
    if (_chestPositions.isEmpty) return;
    final viewportCenter = _offset + _viewportWidth / 2;
    _animateTo(_nearestChestCenter(viewportCenter), vsync);
  }

  /// Animates the camera to center the chest at [index] (clamped to range).
  void snapToIndex(int index, TickerProvider vsync) {
    if (_chestPositions.isEmpty) return;
    final i = index.clamp(0, _chestPositions.length - 1);
    _animateTo(_chestPositions[i], vsync);
  }

  /// Centers the chest at [index] INSTANTLY (no animation) - used to resume
  /// the room exactly where the user left it.
  void jumpToIndex(int index) {
    if (_chestPositions.isEmpty) return;
    final i = index.clamp(0, _chestPositions.length - 1);
    final lo = minOffset;
    final hi = maxOffset;
    final target = _chestPositions[i] - _viewportWidth / 2;
    _offset = lo <= hi ? target.clamp(lo, hi) : (lo + hi) / 2;
    notifyListeners();
  }

  void _animateTo(double targetPosition, TickerProvider vsync) {
    final lo = minOffset;
    final hi = maxOffset;
    final double targetOffset;
    if (lo <= hi) {
      targetOffset = (targetPosition - _viewportWidth / 2).clamp(lo, hi);
    } else {
      targetOffset = (lo + hi) / 2;
    }

    if ((targetOffset - _offset).abs() < 0.5) {
      // Already close enough, just snap directly.
      _offset = targetOffset;
      notifyListeners();
      return;
    }

    _cancelSnap();

    _snapController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 350),
    );

    final startOffset = _offset;
    final distance = targetOffset - startOffset;

    final curved = CurvedAnimation(
      parent: _snapController!,
      curve: Curves.easeOutCubic,
    );

    curved.addListener(() {
      _offset = startOffset + distance * curved.value;
      notifyListeners();
    });

    curved.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _snapController?.dispose();
        _snapController = null;
      }
    });

    _snapController!.forward();
  }

  /// Returns the index of the chest nearest to the viewport center.
  /// Returns -1 if no chest is within 0.4 * viewportWidth of center,
  /// or if there are no chest positions.
  int get focusedIndex {
    if (_chestPositions.isEmpty) return -1;
    final center = _offset + _viewportWidth / 2;
    int nearestIndex = -1;
    double nearestDistance = double.infinity;
    for (int i = 0; i < _chestPositions.length; i++) {
      final distance = (_chestPositions[i] - center).abs();
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }
    if (nearestDistance < _viewportWidth * 0.4) {
      return nearestIndex;
    }
    return -1;
  }

  /// The index of the chest nearest to the viewport center with no distance
  /// threshold (unlike [focusedIndex]). -1 only when there are no positions.
  int get nearestIndex {
    if (_chestPositions.isEmpty) return -1;
    final center = _offset + _viewportWidth / 2;
    var best = 0;
    var bestDistance = double.infinity;
    for (int i = 0; i < _chestPositions.length; i++) {
      final distance = (_chestPositions[i] - center).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = i;
      }
    }
    return best;
  }

  /// Update the chest positions when boxes are added or removed, and the
  /// viewport width on resize/rotation. A width change re-centers the camera
  /// on the chest it was focused on - otherwise a portrait-centered chest
  /// lands off-center after rotating to landscape.
  void updatePositions(List<double> positions, {double? viewportWidth}) {
    final widthChanged = viewportWidth != null &&
        (viewportWidth - _viewportWidth).abs() > 0.5;
    // Which chest was centered BEFORE the geometry changes.
    final focused = widthChanged ? nearestIndex : -1;

    _chestPositions = positions;
    if (widthChanged) _viewportWidth = viewportWidth;

    if (_chestPositions.isEmpty) {
      _offset = 0.0;
    } else if (widthChanged && focused >= 0 &&
        focused < _chestPositions.length) {
      // Re-center the previously focused chest under the new width.
      _cancelSnap();
      final lo = minOffset;
      final hi = maxOffset;
      final target = _chestPositions[focused] - _viewportWidth / 2;
      _offset = lo <= hi ? target.clamp(lo, hi) : (lo + hi) / 2;
    } else {
      final lo = minOffset;
      final hi = maxOffset;
      if (lo <= hi) {
        _offset = _offset.clamp(lo, hi);
      } else {
        // When viewport is wider than the content range, center the content.
        _offset = (lo + hi) / 2;
      }
    }
    notifyListeners();
  }

  /// Finds the chest position closest to a given world-x coordinate.
  double _nearestChestCenter(double x) {
    return _chestPositions.reduce(
      (a, b) => (a - x).abs() < (b - x).abs() ? a : b,
    );
  }

  void _cancelSnap() {
    if (_snapController != null && _snapController!.isAnimating) {
      _snapController!.stop();
      _snapController!.dispose();
      _snapController = null;
    }
  }

  @override
  void dispose() {
    _cancelSnap();
    super.dispose();
  }
}
