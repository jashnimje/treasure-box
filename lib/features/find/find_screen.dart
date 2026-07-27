import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/repositories/inventory_repository.dart';
import '../../core/providers/box_providers.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/data/models/box.dart';
import '../../core/widgets/danger_confirm_dialog.dart';
import '../../core/widgets/item_image.dart';
import '../../core/widgets/minecraft_chest.dart';
import '../../core/widgets/pixel_slot.dart';
import '../../core/widgets/pixel_text_field.dart';
import '../settings/widgets/chest_info_cards.dart';
import 'stats_card.dart';

/// My stuff: the cross-box hub. Search every chest at once, see the latest
/// additions, and manage the chests themselves (open info / delete).
class FindScreen extends ConsumerStatefulWidget {
  const FindScreen({super.key});

  @override
  ConsumerState<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends ConsumerState<FindScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteBox(Box box) async {
    final confirmed = await DangerConfirmDialog.ask(
      context,
      title: 'Delete ${box.name}?',
      message: 'The chest and everything inside it will be gone. '
          'Its code (${box.code}) will be reused by the next new chest. '
          'This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed) {
      await ref.read(inventoryRepositoryProvider).deleteBox(box.id);
      ref.read(activeBoxIdProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;

    return Scaffold(
      backgroundColor: mc.voidDark,
      appBar: AppBar(
        backgroundColor: mc.headerBar,
        foregroundColor: mc.white,
        title: Text('My stuff', style: text.headingPixel),
        shape: Border(bottom: BorderSide(color: mc.obsidianLight, width: 3)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mc.obsidian, mc.obsidianDeep],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: PixelTextField(
                controller: _controller,
                hintText: 'Search all boxes...',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              // With no query: the hub view - your chests (open/delete)
              // and the cross-box activity log.
              child: _query.trim().isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      children: [
                        Text(
                          'MY CHESTS',
                          style: text.labelPixel
                              .copyWith(color: mc.stoneMid, fontSize: 10),
                        ),
                        const SizedBox(height: 10),
                        for (final box in ref
                                .watch(boxesProvider)
                                .valueOrNull ??
                            const <Box>[])
                          _ChestTile(
                            box: box,
                            onOpen: () {
                              ref
                                  .read(activeBoxIdProvider.notifier)
                                  .select(box.id);
                              // push, not go: back returns to this hub and
                              // then to the room, instead of exiting the app.
                              context.push('/inventory');
                            },
                            onDelete: () => _deleteBox(box),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'RECENTLY ADDED - ALL BOXES',
                          style: text.labelPixel
                              .copyWith(color: mc.stoneMid, fontSize: 10),
                        ),
                        const SizedBox(height: 10),
                        const RecentItemsCard(),
                        const SizedBox(height: 16),
                        Text(
                          'STATISTICS',
                          style: text.labelPixel
                              .copyWith(color: mc.stoneMid, fontSize: 10),
                        ),
                        const SizedBox(height: 10),
                        const StatsCard(),
                        const SizedBox(height: 16),
                        Text(
                          'Search above to find which box holds an item.',
                          textAlign: TextAlign.center,
                          style: text.bodyReadable
                              .copyWith(color: mc.stoneDark),
                        ),
                      ],
                    )
                  : FutureBuilder<List<FoundItem>>(
                      // Re-run on each query change; also depends on live items.
                      future: ref
                          .watch(inventoryRepositoryProvider)
                          .findItems(_query),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final results = snap.data!;
                        if (results.isEmpty) {
                          return _Hint(
                            icon: Icons.search_off,
                            message: 'Nothing matches "$_query".',
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                          itemCount: results.length,
                          itemBuilder: (context, i) =>
                              _ResultTile(found: results[i], onTap: () {
                            ref
                                .read(activeBoxIdProvider.notifier)
                                .select(results[i].box.id);
                            context.push(
                                '/inventory/item/${results[i].item.id}');
                          }),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One chest row in the hub: mini chest + name/code, tap to open, trash to
/// delete (with the TNT confirm).
class _ChestTile extends StatelessWidget {
  const _ChestTile({
    required this.box,
    required this.onOpen,
    required this.onDelete,
  });

  final Box box;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: mc.obsidianLight,
          border: Border.all(color: const Color(0xFF33303C), width: 2),
        ),
        child: Row(
          children: [
            MiniChest(size: 40, skinKey: box.skinKey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(box.name,
                      style: text.labelPixel.copyWith(color: mc.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(box.code,
                      style: text.bodyReadable
                          .copyWith(color: mc.gold, fontSize: 14)),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.delete_outline,
                    size: 22, color: mc.redstone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.found, required this.onTap});

  final FoundItem found;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    final item = found.item;
    final where = found.box.name +
        (item.spot != null && item.spot!.isNotEmpty ? '  -  ${item.spot}' : '');
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mc.obsidianLight,
          border: Border.all(color: const Color(0xFF33303C), width: 2),
        ),
        child: Row(
          children: [
            PixelSlot(size: 48, child: ItemImage(item: item, size: 44)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: text.labelPixel.copyWith(color: mc.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 14, color: mc.gold),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(where,
                            style:
                                text.bodyReadable.copyWith(color: mc.gold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: mc.obsidian,
                border: Border.all(color: mc.stoneDark, width: 2),
              ),
              child: Text('x${item.qty}',
                  style: text.numeric.copyWith(color: mc.gold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: mc.stoneDark),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: context.mcText.bodyReadable.copyWith(color: mc.stoneMid)),
        ],
      ),
    );
  }
}
