import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treasure_box/core/update/update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('isNewer', () {
    test('plain increments', () {
      expect(UpdateService.isNewer('1.0.2', '1.0.1'), isTrue);
      expect(UpdateService.isNewer('1.1.0', '1.0.9'), isTrue);
      expect(UpdateService.isNewer('2.0.0', '1.9.9'), isTrue);
    });

    test('equal and older are not newer', () {
      expect(UpdateService.isNewer('1.0.1', '1.0.1'), isFalse);
      expect(UpdateService.isNewer('1.0.0', '1.0.1'), isFalse);
    });

    test('double-digit segments compare numerically, not lexically', () {
      expect(UpdateService.isNewer('1.0.10', '1.0.2'), isTrue);
      expect(UpdateService.isNewer('1.0.2', '1.0.10'), isFalse);
    });

    test('build metadata is ignored', () {
      expect(UpdateService.isNewer('1.0.1+5', '1.0.1'), isFalse);
      expect(UpdateService.isNewer('1.0.2+1', '1.0.1+9'), isTrue);
    });
  });

  group('check', () {
    Map<String, dynamic> release({
      String tag = 'v1.0.2',
      bool prerelease = false,
      List<Map<String, String>> assets = const [],
    }) =>
        {
          'tag_name': tag,
          'draft': false,
          'prerelease': prerelease,
          'body': 'Fixes things.',
          'html_url': 'https://github.com/x/y/releases/tag/$tag',
          'assets': assets,
        };

    UpdateService service(
      Map<String, dynamic> payload, {
      String current = '1.0.1',
      List<String> abis = const ['arm64-v8a'],
    }) =>
        UpdateService(
          currentVersion: current,
          abis: abis,
          client: MockClient((request) async =>
              http.Response(jsonEncode(payload), 200)),
        );

    test('newer release with a matching APK asset', () async {
      final info = await service(release(assets: [
        {
          'name': 'treasure-box-1.0.2-android-arm64.apk',
          'browser_download_url': 'https://dl/arm64.apk',
        },
        {
          'name': 'treasure-box-1.0.2-android-arm32.apk',
          'browser_download_url': 'https://dl/arm32.apk',
        },
      ])).check();
      expect(info, isNotNull);
      expect(info!.version, '1.0.2');
      expect(info.assetUrl, 'https://dl/arm64.apk');
    });

    test('same version -> null', () async {
      final info = await service(release(tag: 'v1.0.1')).check();
      expect(info, isNull);
    });

    test('prerelease -> null', () async {
      final info = await service(release(prerelease: true)).check();
      expect(info, isNull);
    });

    test('no ABI match -> release page fallback (null asset)', () async {
      final info = await service(
        release(assets: [
          {
            'name': 'treasure-box-1.0.2-windows-x64.zip',
            'browser_download_url': 'https://dl/win.zip',
          },
        ]),
      ).check();
      expect(info, isNotNull);
      expect(info!.assetUrl, isNull);
      expect(info.pageUrl, contains('releases'));
    });

    test('API failure -> null, never throws', () async {
      final broken = UpdateService(
        currentVersion: '1.0.1',
        client: MockClient((_) async => http.Response('nope', 500)),
      );
      expect(await broken.check(), isNull);
    });
  });
}
