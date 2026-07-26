import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/data/models/box_code.dart';

void main() {
  group('parseBoxCode', () {
    test('bare code is the ID rail', () {
      final ref = parseBoxCode('BOX-1');
      expect(ref.code, 'BOX-1');
      expect(ref.source, BoxCodeSource.id);
    });

    test('QR envelope is stripped and marks the QR rail', () {
      final ref = parseBoxCode('TB:BOX-1:QR');
      expect(ref.code, 'BOX-1');
      expect(ref.source, BoxCodeSource.qr);
    });

    test('envelope is case-insensitive', () {
      final ref = parseBoxCode('tb:box-2:qr');
      expect(ref.code, 'BOX-2');
      expect(ref.source, BoxCodeSource.qr);
    });

    test('deep link path resolves to its last segment', () {
      final ref = parseBoxCode('https://x/box/TB:BOX-3:QR');
      expect(ref.code, 'BOX-3');
      expect(ref.source, BoxCodeSource.qr);
    });

    test('bare deep link stays on the ID rail', () {
      final ref = parseBoxCode('/box/BOX-4');
      expect(ref.code, 'BOX-4');
      expect(ref.source, BoxCodeSource.id);
    });

    test('whitespace and lowercase codes are canonicalized', () {
      expect(parseBoxCode('  box-7 ').code, 'BOX-7');
      expect(parseBoxCode('BOX7').code, 'BOX-7');
    });

    test('names pass through untouched', () {
      final ref = parseBoxCode('Treasure Box');
      expect(ref.code, 'Treasure Box');
      expect(ref.source, BoxCodeSource.id);
    });

    test('assumeNfc wins over the QR envelope marker', () {
      final ref = parseBoxCode('TB:BOX-1:QR', assumeNfc: true);
      expect(ref.code, 'BOX-1');
      expect(ref.source, BoxCodeSource.nfc);
    });

    test('empty input yields an empty ID ref, never throws', () {
      final ref = parseBoxCode('   ');
      expect(ref.code, isEmpty);
      expect(ref.source, BoxCodeSource.id);
    });
  });

  test('qrEnvelope builds the printed QR string', () {
    expect(qrEnvelope('BOX-9'), 'TB:BOX-9:QR');
  });

  test('qrDeepLink round-trips through parseBoxCode as the QR rail', () {
    final ref = parseBoxCode(qrDeepLink('BOX-2'));
    expect(ref.code, 'BOX-2');
    expect(ref.source, BoxCodeSource.qr);
  });
}
