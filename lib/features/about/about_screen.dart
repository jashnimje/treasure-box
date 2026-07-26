import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/minecraft_chest.dart';
import '../../core/widgets/pixel_button.dart';
import '../../core/widgets/pixel_panel.dart';

/// The three parts of the book - header, body, footer - each editable in
/// the app so the keeper of the chest can make it theirs.
const String kDefaultHeader = '=== The Book of the Chest ===';

const String kDefaultBody = '''
Somewhere in the overworld stands a real chest, and this app is its companion.

Every item placed inside the chest can be stashed here too - with a name, a picture and the spot where it rests. Tap the chest's tag, scan its label, or type its code, and the lid swings open to show what lies within.

No mob drops, no enchanted books. Just the treasures of the real world, kept safe one slot at a time.

Tap the quill to write your own legend on this page.''';

const String kDefaultFooter = '''
Achievement unlocked: [ A Place for Everything ]

Inspired by a certain block game. Also try the real chest!''';

/// One editable, persisted section of the dedication book.
class _SectionNotifier extends FamilyNotifier<String, String> {
  @override
  String build(String key) {
    _load(key);
    return switch (key) {
      'header' => kDefaultHeader,
      'footer' => kDefaultFooter,
      _ => kDefaultBody,
    };
  }

  Future<void> _load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('about_$key');
    if (stored != null && stored.isNotEmpty && stored != state) {
      state = stored;
    }
  }

  Future<void> save(String text) async {
    if (text.trim().isEmpty) return; // keep the previous text
    state = text;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('about_$arg', state);
  }
}

final aboutSectionProvider =
    NotifierProvider.family<_SectionNotifier, String, String>(
        _SectionNotifier.new);

/// About: the personal heart of the app. A lore-book dedication in three
/// editable parts (header / body / footer), signed like a written book,
/// with the large chest - the real one - above it.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final text = context.mcText;

    return Scaffold(
      backgroundColor: mc.voidDark,
      appBar: AppBar(
        backgroundColor: mc.headerBar,
        foregroundColor: mc.white,
        title: Text('About', style: text.headingPixel),
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
        // The book is the page: centered like a Minecraft written book,
        // capped at a readable width, text reflowing to fill it.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                // The real chest: the large trunk, lid open.
                Center(
                  child: SizedBox(
                    width: 190,
                    height: 150,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: MinecraftChest(
                          size: 190, lidOpen: 1, skinKey: 'oak-large'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // The book: header / body / footer, each editable in place.
                PixelPanel(
                  fill: const Color(0xFF2B2437),
                  borderColor: mc.plankTan,
                  borderWidth: 3,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _EditableSection(
                        sectionKey: 'header',
                        align: TextAlign.center,
                        style: text.labelPixel.copyWith(
                            color: mc.gold, fontSize: 12, height: 1.6),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(height: 2, color: mc.obsidianLight),
                      ),
                      _EditableSection(
                        sectionKey: 'body',
                        style: text.bodyReadable.copyWith(
                            color: mc.white, height: 1.5, fontSize: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(height: 2, color: mc.obsidianLight),
                      ),
                      _EditableSection(
                        sectionKey: 'footer',
                        style: text.bodyReadable.copyWith(
                            color: mc.stoneLight, height: 1.5, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A book section that flips between reading and editing. The pencil sits
/// under the text; saving "signs" the section into local storage.
class _EditableSection extends ConsumerStatefulWidget {
  const _EditableSection({
    required this.sectionKey,
    required this.style,
    this.align = TextAlign.start,
  });

  final String sectionKey;
  final TextStyle style;
  final TextAlign align;

  @override
  ConsumerState<_EditableSection> createState() => _EditableSectionState();
}

class _EditableSectionState extends ConsumerState<_EditableSection> {
  bool _editing = false;
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    final value = ref.watch(aboutSectionProvider(widget.sectionKey));

    if (_editing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            maxLines: null,
            textAlign: widget.align,
            style: widget.style,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Write the legend...',
              hintStyle: text.bodyReadable.copyWith(color: mc.stoneDark),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: PixelButton(
                  height: 36,
                  onPressed: () => setState(() => _editing = false),
                  child: Text('Cancel',
                      style: text.labelPixel
                          .copyWith(color: mc.white, fontSize: 10)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PixelButton(
                  height: 36,
                  variant: PixelButtonVariant.grass,
                  onPressed: () async {
                    await ref
                        .read(aboutSectionProvider(widget.sectionKey).notifier)
                        .save(_controller.text);
                    if (mounted) setState(() => _editing = false);
                  },
                  child: Text('Sign',
                      style: text.labelPixel
                          .copyWith(color: mc.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(value, textAlign: widget.align, style: widget.style),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              _controller.text = value;
              setState(() => _editing = true);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child:
                  Icon(Icons.edit_outlined, size: 15, color: mc.stoneDark),
            ),
          ),
        ),
      ],
    );
  }
}
