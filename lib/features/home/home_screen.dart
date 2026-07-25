import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/models/box.dart';
import '../../core/data/models/box_code.dart';
import '../../core/game/mine_points.dart';
import '../../core/platform/nfc_service_factory.dart';
import '../../core/providers/box_providers.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/pixel_icon.dart';
import '../scan/scan_screen.dart';
import 'open_sequence_controller.dart';
import 'widgets/room_viewport.dart';

/// The home screen: an immersive panoramic room with the active chest locked
/// center stage. Drag to look around the room; tap the centered chest (or an
/// NFC tap on mobile) to open it with a cinematic zoom/lid/tilt/fade dive
/// into the inventory.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final OpenSequenceController _openSequence;
  final _viewportKey = GlobalKey<RoomViewportState>();

  /// Index of the chest currently being opened (drives lidOpenValue).
  int? _openingBoxIndex;

  /// When NFC resolves a box, the camera pans to it before opening.
  int? _focusBoxIndex;

  @override
  void initState() {
    super.initState();
    _openSequence = OpenSequenceController(
      vsync: this,
      onComplete: _onOpenComplete,
    );
    _consumePendingOpen();
  }

  /// A deep link (NFC tap / QR scan) landed us here with a box to open:
  /// the camera starts on it (initialBoxIndex), we play the lid animation.
  Future<void> _consumePendingOpen() async {
    final boxId = ref.read(pendingOpenProvider.notifier).consume();
    if (boxId == null) return;
    final boxes = await ref.read(boxesProvider.future);
    if (!mounted) return;
    final index = boxes.indexWhere((b) => b.id == boxId);
    if (index >= 0) {
      // One frame for the room to lay out, then open.
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (mounted && !_openSequence.isActive) {
        _openChest(boxes[index], index);
      }
    }
  }

  /// Opens a chest: sets the active box provider, stores the opening index,
  /// and starts the open sequence. If the chest is not the centered one, the
  /// camera pans to it first so the lid always opens center-stage.
  Future<void> _openChest(Box box, int index) async {
    if (_openSequence.isActive) return;
    ref.read(activeBoxIdProvider.notifier).select(box.id);

    final centered = _viewportKey.currentState?.nearestBoxIndex == index;
    if (!centered) {
      setState(() => _focusBoxIndex = index);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted || _openSequence.isActive) return;
    }

    setState(() {
      _openingBoxIndex = index;
    });
    _openSequence.start();
  }

  /// Called when the fade phase completes: navigate to inventory.
  void _onOpenComplete() {
    if (mounted) context.go('/inventory');
  }

  /// A small time-of-day flavor line - the cave greets you differently on
  /// each visit (poke around: torches spark, ores hide in the wall).
  String _caveGreeting() {
    final h = DateTime.now().hour;
    if (h < 6) return 'The cave never sleeps...';
    if (h < 12) return 'Morning light on the stone.';
    if (h < 18) return 'The torches are lit for you.';
    return 'Evening echoes in the deep.';
  }

  /// The scan entry: opens the camera QR scanner; scanning a printed label
  /// resolves and opens its box. "Type instead" falls back to the dialog.
  Future<void> _scanCode() async {
    final raw = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (!mounted || raw == null) return;
    if (raw == ScanScreen.typeInstead) {
      await _openByCode();
      return;
    }
    await _resolveAndOpen(raw);
  }

  /// Open a box by any code a label can carry: QR token, box id, or name.
  Future<void> _openByCode() async {
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => const _CodeEntryDialog(),
    );
    if (code == null || code.trim().isEmpty || !mounted) return;
    await _resolveAndOpen(code);
  }

  /// Resolve any raw code (typed, scanned, pasted) and open its chest,
  /// stamping the QR rail when the envelope says the code came from a scan.
  Future<void> _resolveAndOpen(String code) async {
    final repo = ref.read(inventoryRepositoryProvider);
    final box = await repo.boxByAnyCode(code);
    // A pasted QR envelope (TB:BOX-N:QR) still counts as the QR rail.
    if (box != null && parseBoxCode(code).source == BoxCodeSource.qr) {
      await repo.markOpenedVia(box.id, BoxCodeSource.qr);
    }
    if (!mounted) return;
    if (box == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: context.mc.redstone,
          content: Text(
            'No box matches "${code.trim()}"',
            style: context.mcText.bodyReadable
                .copyWith(color: context.mc.white),
          ),
        ),
      );
      return;
    }
    final boxes = ref.read(boxesProvider).valueOrNull ?? [];
    final index = boxes.indexWhere((b) => b.id == box.id);
    if (index >= 0) {
      setState(() => _focusBoxIndex = index);
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (mounted) _openChest(boxes[index], index);
    }
  }

  @override
  void dispose() {
    _openSequence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // NFC tap while the room is already open: consume the request live.
    ref.listen(pendingOpenProvider, (previous, next) {
      if (next != null) _consumePendingOpen();
    });

    final boxesAsync = ref.watch(boxesProvider);
    final mc = context.mc;
    final text = context.mcText;
    final nfcAvailable = ref.watch(nfcAvailableProvider).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: mc.voidDark,
      body: boxesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: mc.gold),
        ),
        error: (e, _) => _RoomError(message: '$e'),
        data: (boxes) {
          // The whole room rebuilds inside AnimatedBuilder so lidOpenValue
          // and pushScale update every animation frame. (Passing the room as
          // AnimatedBuilder's cached `child` freezes the lid - do not.)
          return AnimatedBuilder(
            animation: _openSequence,
            builder: (context, _) {
              Widget roomContent = Stack(
            fit: StackFit.expand,
            children: [
              RoomViewport(
                key: _viewportKey,
                boxes: boxes,
                onTapChest: (index) => _openChest(boxes[index], index),
                onTapAdd: () => context.push('/create-box'),
                onOreMined: (points) =>
                    ref.read(minePointsProvider.notifier).add(points),
                lidOpenIndex:
                    _openSequence.isActive ? _openingBoxIndex : null,
                lidOpenValue:
                    _openSequence.isActive ? _openSequence.lidOpenValue : null,
                focusBoxIndex: _focusBoxIndex,
                // Resume the camera ON the last-opened box, no animation.
                initialBoxIndex: () {
                  final id = ref.read(activeBoxIdProvider);
                  if (id == null) return null;
                  final i = boxes.indexWhere((b) => b.id == id);
                  return i < 0 ? null : i;
                }(),
              ),

              // Mining points tally, small and quiet in the top-right.
              Positioned(
                top: 8,
                right: 10,
                child: SafeArea(
                  child: _PointsChip(points: ref.watch(minePointsProvider)),
                ),
              ),

              // Title, embedded in the world: dim, low-contrast, no card.
              // SafeArea keeps it below the camera cutout in fullscreen.
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SafeArea(
                  bottom: false,
                  minimum: const EdgeInsets.only(top: 24),
                  child: IgnorePointer(
                  child: Column(
                    children: [
                      Text(
                        'TREASURE ROOM',
                        textAlign: TextAlign.center,
                        style: text.headingPixel.copyWith(
                          color: mc.stoneLight.withValues(alpha: 0.85),
                          shadows: [
                            Shadow(
                              color: mc.voidDark,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        boxes.isEmpty
                            ? 'Place your first chest'
                            : nfcAvailable
                                ? 'Tap your chest\'s tag - or tap it here'
                                : 'Tap the chest to open it',
                        textAlign: TextAlign.center,
                        style: text.bodyReadable.copyWith(
                          color: mc.stoneMid.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _caveGreeting(),
                        textAlign: TextAlign.center,
                        style: text.bodyReadable.copyWith(
                          fontSize: 14,
                          color: mc.stoneDark.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),

              // Quiet bottom entries, embedded in the scene. Each chip
              // shares the row width equally so nothing ever overflows,
              // whatever the device width.
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuietEntry(
                            icon: Icons.search,
                            label: 'My stuff',
                            onTap: () => context.push('/find'),
                          ),
                        ),
                        if (boxes.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuietEntry(
                              icon: Icons.qr_code_scanner,
                              label: 'Scan',
                              onTap: _scanCode,
                            ),
                          ),
                        ],
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuietEntry(
                            icon: Icons.menu_book_outlined,
                            label: 'About',
                            onTap: () => context.push('/about'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );

              // While opening, the world stays put: only a gentle camera
              // push-in. The lid swings on the chest itself and the inventory
              // chunk-loads over the room via the block-wipe transition.
              if (_openSequence.isActive) {
                roomContent = Transform.scale(
                  scale: _openSequence.pushScale,
                  alignment: const Alignment(0, 0.25),
                  child: roomContent,
                );
              }

              return roomContent;
            },
          );
        },
      ),
    );
  }
}

/// The lifetime mining tally: a small pickaxe + points chip. Hidden until
/// the first ore is broken so new users see a clean room.
class _PointsChip extends StatelessWidget {
  const _PointsChip({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    if (points <= 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: mc.obsidianDeep.withValues(alpha: 0.66),
          border: Border.all(
            color: mc.obsidianLight.withValues(alpha: 0.85),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelIcon('pickaxe', size: 13, tint: mc.gold),
            const SizedBox(width: 5),
            Text(
              '$points',
              style: context.mcText.labelPixel
                  .copyWith(color: mc.gold, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

/// A quiet, in-world entry chip: translucent dark fill so it sits inside the
/// scene rather than floating above it.
class _QuietEntry extends StatelessWidget {
  const _QuietEntry({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: mc.obsidianDeep.withValues(alpha: 0.66),
          border: Border.all(
            color: mc.obsidianLight.withValues(alpha: 0.85),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: mc.stoneMid, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.mcText.bodyReadable.copyWith(
                  color: mc.stoneLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for opening a box by code: QR token, numeric box id, or name.
class _CodeEntryDialog extends StatefulWidget {
  const _CodeEntryDialog();

  @override
  State<_CodeEntryDialog> createState() => _CodeEntryDialogState();
}

class _CodeEntryDialogState extends State<_CodeEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: mc.obsidianDeep.withValues(alpha: 0.96),
          border: Border.all(color: mc.obsidianLight, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OPEN BY CODE',
                style: text.labelPixel.copyWith(color: mc.stoneLight)),
            const SizedBox(height: 8),
            Text(
              'Type the box code, id, or name from its label.',
              style: text.bodyReadable.copyWith(color: mc.stoneMid),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              style: text.bodyReadable.copyWith(color: mc.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: mc.slotInner,
                hintText: 'e.g. BOX-1 or 1 or Treasure Box',
                hintStyle: text.bodyReadable.copyWith(color: mc.stoneDark),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: mc.slotBorder, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: mc.diamond, width: 2),
                ),
              ),
              onSubmitted: (v) => Navigator.of(context).pop(v),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel',
                      style:
                          text.bodyReadable.copyWith(color: mc.stoneMid)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_controller.text),
                  child: Text('Open',
                      style: text.bodyReadable.copyWith(color: mc.diamond)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Themed error state for the room stream.
class _RoomError extends StatelessWidget {
  const _RoomError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: mc.redstone, size: 48),
            const SizedBox(height: 16),
            Text(
              'The room failed to load',
              style: text.headingPixel.copyWith(color: mc.redstone),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyReadable.copyWith(color: mc.stoneMid),
            ),
          ],
        ),
      ),
    );
  }
}
