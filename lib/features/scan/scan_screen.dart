import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/minecraft_theme.dart';
import '../../core/widgets/pixel_button.dart';

/// Camera QR scanner: point at a printed box label and pop with the raw
/// value (deep link or enveloped code - the caller resolves it). A "Type
/// instead" fallback pops with the sentinel [typeInstead] so the caller can
/// open the code dialog. Camera-less platforms get the fallback UI directly.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  /// Sentinel returned when the user chooses to type the code instead.
  static const typeInstead = '__TYPE__';

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _done = false;
  String? _error;

  bool get _cameraLikely =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.trim().isNotEmpty) {
        _done = true;
        Navigator.of(context).pop(value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final text = context.mcText;

    return Scaffold(
      backgroundColor: mc.voidDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.arrow_back, color: mc.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Text('SCAN A BOX LABEL',
                      style: text.labelPixel.copyWith(color: mc.stoneLight)),
                ],
              ),
            ),
            Expanded(
              child: !_cameraLikely || _error != null
                  ? _Fallback(error: _error)
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        MobileScanner(
                          controller: _controller,
                          onDetect: _onDetect,
                          errorBuilder: (context, exception) {
                            // Render the themed fallback on camera failure
                            // (no permission, no camera, emulator).
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && _error == null) {
                                setState(() =>
                                    _error = exception.errorCode.name);
                              }
                            });
                            return const SizedBox.shrink();
                          },
                        ),
                        // Pixel-styled viewfinder frame.
                        Center(
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              border: Border.all(color: mc.diamond, width: 3),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Point at the QR on the box',
                              style: text.bodyReadable
                                  .copyWith(color: mc.stoneLight),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: PixelButton(
                width: double.infinity,
                onPressed: () =>
                    Navigator.of(context).pop(ScanScreen.typeInstead),
                child: Text('Type the code instead',
                    style: text.labelPixel.copyWith(color: mc.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when no camera is available (desktop, denied permission).
class _Fallback extends StatelessWidget {
  const _Fallback({this.error});

  final String? error;

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
            Icon(Icons.no_photography_outlined, color: mc.stoneMid, size: 48),
            const SizedBox(height: 16),
            Text(
              error == null
                  ? 'No camera on this device'
                  : 'Camera unavailable ($error)',
              textAlign: TextAlign.center,
              style: text.bodyReadable.copyWith(color: mc.stoneMid),
            ),
            const SizedBox(height: 8),
            Text(
              'Use "Type the code instead" below.',
              textAlign: TextAlign.center,
              style: text.bodyReadable.copyWith(color: mc.stoneLight),
            ),
          ],
        ),
      ),
    );
  }
}
