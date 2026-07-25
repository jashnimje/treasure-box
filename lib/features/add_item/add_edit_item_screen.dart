import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/models/item.dart';
import '../../core/data/models/item_category.dart';
import '../../core/data/models/rarity.dart';
import '../../core/providers/box_providers.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/pixel_button.dart';
import '../../core/widgets/pixel_stepper.dart';
import '../../core/widgets/pixel_text_field.dart';
import '../../core/widgets/wooden_dropdown.dart';
import 'widgets/icon_picker.dart';
import 'widgets/photo_picker.dart';

/// Add or edit an item. One screen, two modes: [editItemId] null = add.
class AddEditItemScreen extends ConsumerStatefulWidget {
  const AddEditItemScreen({super.key, this.editItemId});

  final int? editItemId;

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  ItemCategory _category = ItemCategory.weapons;
  String _iconKey = 'sword';
  int _qty = 1;
  Rarity _rarity = Rarity.common;
  String? _photoPath;

  bool _initialized = false;
  bool _saving = false;

  bool get _isEdit => widget.editItemId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _hydrateFrom(Item item) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = item.name;
    _notesController.text = item.notes ?? '';
    _category = item.category;
    _iconKey = item.iconKey;
    _qty = item.qty;
    _rarity = item.rarity;
    _photoPath = item.photoPath;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _snack('Give the item a name');
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(inventoryRepositoryProvider);
    final box = await ref.read(activeBoxProvider.future);

    // Capacity is enforced on add only (editing a stack never adds a slot).
    if (!_isEdit) {
      final used = await repo.slotCount(box.id);
      if (used >= box.capacity) {
        setState(() => _saving = false);
        _snack('Chest is full - $used/${box.capacity} slots');
        return;
      }
    }

    await repo.upsertItem(
      box.id,
      ItemDraft(
        id: widget.editItemId,
        name: name,
        category: _category,
        iconKey: _iconKey,
        qty: _qty,
        rarity: _rarity,
        photoPath: _photoPath,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
    if (mounted) Navigator.of(context).maybePop();
  }

  void _snack(String message) {
    final mc = context.mc;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: mc.redstone,
        content: Text(message,
            style: context.mcText.bodyReadable.copyWith(color: mc.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;

    // In edit mode, hydrate the form from the live item once available.
    if (_isEdit) {
      final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
      final item = items.where((i) => i.id == widget.editItemId).firstOrNull;
      if (item != null) _hydrateFrom(item);
    }

    return Scaffold(
      backgroundColor: mc.voidDark,
      appBar: AppBar(
        backgroundColor: mc.headerBar,
        foregroundColor: mc.white,
        title: Text(_isEdit ? 'Edit item' : 'Add item',
            style: text.headingPixel),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
        children: [
          _Label('SELECT ICON'),
          IconPicker(
            selected: _iconKey,
            onSelect: (k) => setState(() => _iconKey = k),
          ),
          const SizedBox(height: 20),
          _Label('ITEM NAME'),
          PixelTextField(
            controller: _nameController,
            hintText: 'e.g. Iron Sword',
          ),
          const SizedBox(height: 20),
          _Label('CATEGORY'),
          WoodenDropdown<ItemCategory>(
            value: _category,
            items: ItemCategory.values,
            labelOf: (c) => c.label,
            onChanged: (c) => setState(() => _category = c),
          ),
          const SizedBox(height: 20),
          _Label('RARITY'),
          _RaritySelector(
            value: _rarity,
            onChanged: (r) => setState(() => _rarity = r),
          ),
          const SizedBox(height: 20),
          _Label('QUANTITY'),
          PixelStepper(
            value: _qty,
            min: 1,
            max: 9999,
            onChanged: (v) => setState(() => _qty = v),
          ),
          const SizedBox(height: 20),
          _Label('PHOTO'),
          PhotoPicker(
            photoPath: _photoPath,
            onChanged: (p) => setState(() => _photoPath = p),
          ),
          const SizedBox(height: 20),
          _Label('NOTES'),
          PixelTextField(
            controller: _notesController,
            hintText: 'Optional notes...',
            maxLines: 3,
          ),
          const SizedBox(height: 28),
          PixelButton(
            variant: PixelButtonVariant.grass,
            width: double.infinity,
            height: 52,
            onPressed: _saving ? null : _save,
            child: Text(
              _saving ? 'Saving...' : 'Save to chest',
              style: text.labelPixel.copyWith(color: mc.white),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: context.mcText.labelPixel.copyWith(color: context.mc.stoneMid),
      ),
    );
  }
}

class _RaritySelector extends StatelessWidget {
  const _RaritySelector({required this.value, required this.onChanged});

  final Rarity value;
  final ValueChanged<Rarity> onChanged;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final r in Rarity.values)
          GestureDetector(
            onTap: () => onChanged(r),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: r == value ? mc.obsidianLight : mc.obsidian,
                border: Border.all(
                  color: r == value ? r.color(mc) : mc.stoneDark,
                  width: 2,
                ),
              ),
              child: Text(
                r.label,
                style: context.mcText.bodyReadable.copyWith(
                  color: r == value ? r.color(mc) : mc.stoneLight,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
