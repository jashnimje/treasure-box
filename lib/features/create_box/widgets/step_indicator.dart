import 'package:flutter/material.dart';

import '../../../core/theme/minecraft_theme.dart';

/// A row of pixel-styled slots indicating wizard progress.
///
/// Completed steps are filled with diamond color; remaining steps are
/// outlined. A "Step N of M" label in PressStart2P sits below the slots.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  /// Zero-indexed current step.
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final label = context.mcText.labelPixel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totalSteps, (i) {
            final completed = i <= currentStep;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: completed ? mc.diamond : mc.slotInner,
                  border: Border.all(
                    color: completed ? mc.diamond : mc.slotBorder,
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Step ${currentStep + 1} of $totalSteps',
          style: label.copyWith(color: mc.stoneMid, fontSize: 10),
        ),
      ],
    );
  }
}
