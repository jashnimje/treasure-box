import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'update_service.dart';

/// Installed app version, e.g. `1.0.1`.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

final updateServiceProvider = FutureProvider<UpdateService>((ref) async {
  final version = await ref.watch(appVersionProvider.future);
  var abis = const <String>[];
  if (!kIsWeb && Platform.isAndroid) {
    final android = await DeviceInfoPlugin().androidInfo;
    abis = android.supportedAbis;
  }
  return UpdateService(currentVersion: version, abis: abis);
});

/// The available update, if any. Checked once per app session (cached with
/// a TTL underneath); refresh with `ref.refresh` for a manual re-check.
final availableUpdateProvider = FutureProvider<UpdateInfo?>((ref) async {
  final service = await ref.watch(updateServiceProvider.future);
  return service.check();
});
