import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/models/box.dart';
import '../../core/data/models/box_code.dart';
import '../../core/providers/box_providers.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/pixel_button.dart';

/// Deep-link target: `/box/<code>` resolves a box by QR token, numeric id, or
/// name and drops straight into its inventory. This is what a printed QR code
/// or a shared link opens. An unknown code gets a themed error with a way
/// back to the room.
class BoxLinkScreen extends ConsumerStatefulWidget {
  const BoxLinkScreen({super.key, required this.code});

  final String code;

  @override
  ConsumerState<BoxLinkScreen> createState() => _BoxLinkScreenState();
}

class _BoxLinkScreenState extends ConsumerState<BoxLinkScreen> {
  bool _resolved = false;
  bool _unknown = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final repo = ref.read(inventoryRepositoryProvider);
    final Box? box = await repo.boxByAnyCode(widget.code);
    if (box != null) {
      // The rail is carried by the envelope: a scanned QR label arrives as
      // TB:BOX-N:QR, a bare code (typed / shared link) as BOX-N.
      final source = parseBoxCode(widget.code).source;
      if (source != BoxCodeSource.id) {
        await repo.markOpenedVia(box.id, source);
      }
    }
    if (!mounted) return;
    if (box == null) {
      setState(() {
        _resolved = true;
        _unknown = true;
      });
      return;
    }
    // Route through the ROOM so the chest opens with the cinematic lid
    // animation (the signature moment), instead of teleporting straight
    // into the inventory list. Navigate first, then request: the request
    // must reach the home instance that survives the navigation. The
    // notifier is captured up front - it is app-scoped and outlives this
    // screen, whose own ref dies with the go().
    ref.read(activeBoxIdProvider.notifier).select(box.id);
    final pending = ref.read(pendingOpenProvider.notifier);
    context.go('/');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    pending.request(box.id);
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;

    return Scaffold(
      backgroundColor: mc.voidDark,
      body: Center(
        child: !_resolved
            ? CircularProgressIndicator(color: mc.gold)
            : !_unknown
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.help_outline,
                            color: mc.stoneMid, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Unknown box code',
                          style:
                              text.headingPixel.copyWith(color: mc.stoneLight),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '"${widget.code}" does not match any of your '
                          'boxes. Check the label or QR and try again.',
                          textAlign: TextAlign.center,
                          style:
                              text.bodyReadable.copyWith(color: mc.stoneMid),
                        ),
                        const SizedBox(height: 24),
                        PixelButton(
                          onPressed: () => context.go('/'),
                          child: Text(
                            'Back to the room',
                            style:
                                text.labelPixel.copyWith(color: mc.white),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
