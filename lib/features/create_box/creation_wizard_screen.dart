import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/pixel_button.dart';
import '../../core/widgets/pixel_panel.dart';
import '../../core/widgets/pixel_text_field.dart';
import 'widgets/skin_picker.dart';
import 'widgets/step_indicator.dart';

/// Full-screen box creation wizard with crafting-table visual motif.
///
/// Two steps:
/// 1. Name the box (PixelTextField with slot-style border)
/// 2. Choose chest skin (horizontal scroll of MinecraftChest previews)
///
/// On final step confirm: calls `repository.createBox(name: name)`.
/// On success: dismisses via Navigator.pop.
/// On failure: shows redstone-colored error SnackBar; does not dismiss.
/// On dismiss before completion: discards partial state and pops.
class CreationWizardScreen extends ConsumerStatefulWidget {
  const CreationWizardScreen({super.key});

  @override
  ConsumerState<CreationWizardScreen> createState() =>
      _CreationWizardScreenState();
}

class _CreationWizardScreenState extends ConsumerState<CreationWizardScreen> {
  static const _totalSteps = 2;

  int _currentStep = 0;
  final _nameController = TextEditingController();
  String _selectedSkin = 'oak';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(inventoryRepositoryProvider);
      await repository.createBox(name: name, skinKey: _selectedSkin);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: context.mc.redstone,
            content: Text(
              'Failed to create box: $e',
              style: context.mcText.bodyReadable.copyWith(
                color: context.mc.white,
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onNext() {
    if (_currentStep == 0) {
      final name = _nameController.text.trim();
      if (name.isEmpty) return;
      setState(() => _currentStep = 1);
    } else {
      _onConfirm();
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final headingStyle = context.mcText.headingPixel;

    return Scaffold(
      backgroundColor: mc.voidDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button and step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _onBack,
                    child: Icon(Icons.arrow_back, color: mc.white, size: 24),
                  ),
                  const Spacer(),
                  StepIndicator(
                    currentStep: _currentStep,
                    totalSteps: _totalSteps,
                  ),
                  const Spacer(),
                  const SizedBox(width: 24), // balance the back button
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PixelPanel(
                    fill: mc.obsidianLight,
                    borderColor: mc.plankTan,
                    borderWidth: 3,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Step title
                        Text(
                          _currentStep == 0 ? 'Name Your Box' : 'Choose Skin',
                          style: headingStyle.copyWith(color: mc.gold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Step content
                        if (_currentStep == 0) _buildNameStep(),
                        if (_currentStep == 1) _buildSkinStep(),

                        const SizedBox(height: 32),

                        // Action button
                        Center(
                          child: PixelButton(
                            variant: PixelButtonVariant.grass,
                            onPressed: _isSubmitting ? null : _onNext,
                            height: 48,
                            width: 200,
                            child: Text(
                              _currentStep == _totalSteps - 1
                                  ? 'Craft'
                                  : 'Next',
                              style: headingStyle.copyWith(
                                color: mc.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    final mc = context.mc;
    final body = context.mcText.bodyReadable;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Give your treasure chest a name:',
          style: body.copyWith(color: mc.stoneMid),
        ),
        const SizedBox(height: 12),
        PixelTextField(
          controller: _nameController,
          hintText: 'My Treasure...',
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildSkinStep() {
    final mc = context.mc;
    final body = context.mcText.bodyReadable;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick a wood style for your chest:',
          style: body.copyWith(color: mc.stoneMid),
        ),
        const SizedBox(height: 12),
        SkinPicker(
          selectedSkin: _selectedSkin,
          onSkinSelected: (key) => setState(() => _selectedSkin = key),
        ),
      ],
    );
  }
}
