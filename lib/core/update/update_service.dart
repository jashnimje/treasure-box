import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A newer release found on GitHub.
class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.changelog,
    required this.pageUrl,
    this.assetUrl,
  });

  /// Version of the newer release (no leading v), e.g. `1.0.2`.
  final String version;

  /// Release notes body (markdown from GitHub).
  final String changelog;

  /// The release page (fallback + non-Android platforms).
  final String pageUrl;

  /// Direct download for THIS device (the matching APK on Android).
  final String? assetUrl;
}

/// Checks GitHub releases for a newer version. No forced updates, no
/// background polling - one throttled check per app start plus a manual
/// button in Settings. The releases payload is cached with a TTL + ETag so
/// repeated checks cost a 304, not a re-download.
class UpdateService {
  UpdateService({
    required this.currentVersion,
    this.abis = const [],
    http.Client? client,
    this.repo = 'jashnimje/treasure-box',
  }) : _client = client ?? http.Client();

  /// Installed version, e.g. `1.0.1` (PackageInfo.version).
  final String currentVersion;

  /// Device ABIs in preference order (Android; empty elsewhere).
  final List<String> abis;

  final String repo;
  final http.Client _client;

  static const _cacheTtl = Duration(hours: 6);
  static const _bodyKey = 'update_latest_release_json';
  static const _atKey = 'update_latest_release_fetched_at';
  static const _etagKey = 'update_latest_release_etag';

  /// Returns the newer release, or null when up to date / offline / API
  /// error (never throws - updates must not break app start).
  Future<UpdateInfo?> check({bool force = false}) async {
    try {
      final body = await _fetchLatest(force: force);
      if (body == null) return null;
      final release = jsonDecode(body);
      if (release is! Map<String, dynamic>) return null;
      if (release['draft'] == true || release['prerelease'] == true) {
        return null;
      }

      final tag = (release['tag_name'] as String? ?? '');
      final remote = tag.startsWith('v') ? tag.substring(1) : tag;
      if (remote.isEmpty || !isNewer(remote, currentVersion)) return null;

      return UpdateInfo(
        version: remote,
        changelog: release['body'] as String? ?? '',
        pageUrl: release['html_url'] as String? ??
            'https://github.com/$repo/releases/latest',
        assetUrl: _pickAsset(release['assets']),
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> _fetchLatest({required bool force}) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_bodyKey);
    final fetchedAt = prefs.getInt(_atKey) ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - fetchedAt;
    if (!force && cached != null && age < _cacheTtl.inMilliseconds) {
      return cached;
    }

    final etag = prefs.getString(_etagKey);
    final response = await _client.get(
      Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        if (!force && cached != null && etag != null) 'If-None-Match': etag,
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 304 && cached != null) {
      await prefs.setInt(_atKey, DateTime.now().millisecondsSinceEpoch);
      return cached;
    }
    if (response.statusCode != 200) return cached; // stale beats nothing
    await prefs.setString(_bodyKey, response.body);
    final newTag = response.headers['etag'];
    if (newTag != null) await prefs.setString(_etagKey, newTag);
    await prefs.setInt(_atKey, DateTime.now().millisecondsSinceEpoch);
    return response.body;
  }

  /// The release asset matching this device: `-android-arm64.apk` for an
  /// arm64 phone, etc. Null on non-Android (button opens the release page).
  String? _pickAsset(dynamic assets) {
    if (assets is! List || abis.isEmpty) return null;
    // Our CI naming -> ABI it serves.
    const abiSuffix = {
      'arm64-v8a': '-android-arm64.apk',
      'armeabi-v7a': '-android-arm32.apk',
      'x86_64': '-android-x86_64.apk',
    };
    for (final abi in abis) {
      final suffix = abiSuffix[abi];
      if (suffix == null) continue;
      for (final asset in assets) {
        if (asset is Map<String, dynamic> &&
            (asset['name'] as String? ?? '').endsWith(suffix)) {
          return asset['browser_download_url'] as String?;
        }
      }
    }
    return null;
  }

  /// Loose semver compare on dotted numerics: `1.0.10` > `1.0.2`, build
  /// metadata (`+n`) ignored. Non-numeric parts compare as 0.
  @visibleForTesting
  static bool isNewer(String remote, String local) {
    List<int> parts(String v) => v
        .split('+')
        .first
        .split('.')
        .map((p) => int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final r = parts(remote);
    final l = parts(local);
    for (var i = 0; i < 3; i++) {
      final rv = i < r.length ? r[i] : 0;
      final lv = i < l.length ? l[i] : 0;
      if (rv != lv) return rv > lv;
    }
    return false;
  }
}
