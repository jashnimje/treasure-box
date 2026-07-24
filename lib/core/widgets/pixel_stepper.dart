import 'package:flutter/material.dart';

import '../theme/minecraft_theme.dart';
import 'pixel_button.dart';

/// A minus/value/plus stepper built from stone buttons, matching the mock's
/// quantity and capacity controls.
class PixelStepper extends StatelessWidget {
  const PixelStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 9999,
    this.step = 1,
    this.suffix,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;

  /// Optional small label under the value (e.g. "SLOTS").
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;
    return Row(
      children: [
        PixelButton(
          width: 48,
          height: 48,
          padding: EdgeInsets.zero,
          onPressed: value > min
              ? () => onChanged((value - step).clamp(min, max))
              : null,
          child: Text('-', style: text.headingPixel.copyWith(color: mc.white)),
        ),
        Expanded(
          child: Container(
            height: 48,
            color: mc.slotInner,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$value', style: text.numeric.copyWith(color: mc.gold)),
                if (suffix != null)
                  Text(
                    suffix!,
                    style: text.labelPixel
                        .copyWith(color: mc.stoneDark, fontSize: 8),
                  ),
              ],
            ),
          ),
        ),
        PixelButton(
          width: 48,
          height: 48,
          padding: EdgeInsets.zero,
          onPressed: value < max
              ? () => onChanged((value + step).clamp(min, max))
              : null,
          child: Text('+', style: text.headingPixel.copyWith(color: mc.white)),
        ),
      ],
    );
  }
}
