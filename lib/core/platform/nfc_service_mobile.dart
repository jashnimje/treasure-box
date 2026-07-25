import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io' show Platform;

import 'package:nfc_manager/nfc_manager.dart' as nfc;

import 'nfc_service.dart';

/// Real NFC on Android/iOS via `nfc_manager`. On other native platforms
/// (macOS/Windows/Linux) NFC is not supported, so this reports unavailable.
class MobileNfcService implements NfcService {
  bool get _supportedPlatform => Platform.isAndroid || Platform.isIOS;

  /// The one in-flight wait, so [stop] can abort it (e.g. on app pause -
  /// Android silently tears reader sessions down in the background, which
  /// would otherwise leave a waiter that never resolves).
  Completer<NfcTag>? _waiter;

  @override
  bool get supportsSimulation => false;

  @override
  void simulateTap() {}

  @override
  Future<bool> isAvailable() async {
    if (!_supportedPlatform) return false;
    try {
      return await nfc.NfcManager.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<NfcTag> waitForTag() async {
    if (!await isAvailable()) {
      throw const NfcUnavailable();
    }
    final existing = _waiter;
    if (existing != null && !existing.isCompleted) {
      return existing.future; // one session at a time
    }
    final completer = Completer<NfcTag>();
    _waiter = completer;
    try {
      await nfc.NfcManager.instance.startSession(
        alertMessage: 'Hold your phone against the box',
        onDiscovered: (tag) async {
          if (!completer.isCompleted) {
            completer.complete(
              NfcTag(_idFromTag(tag), payload: _payloadFromTag(tag)),
            );
          }
          await nfc.NfcManager.instance.stopSession();
        },
        onError: (error) async {
          if (!completer.isCompleted) {
            completer.completeError(NfcUnavailable(error.message));
          }
        },
      );
    } catch (e) {
      // startSession itself can throw (stale prior session, NFC toggled).
      if (!completer.isCompleted) {
        completer.completeError(NfcUnavailable('$e'));
      }
    }
    return completer.future;
  }

  @override
  Future<String> writeTag(String payload, {String? boxName}) async {
    if (!await isAvailable()) {
      throw const NfcUnavailable();
    }
    final completer = Completer<String>();
    await nfc.NfcManager.instance.startSession(
      alertMessage: 'Hold your phone against the box to write its code',
      onDiscovered: (tag) async {
        try {
          final ndef = nfc.Ndef.from(tag);
          if (ndef != null && ndef.isWritable) {
            // Two records (NTAG216 has 888 bytes - room to spare):
            // 1. URI record so Android auto-opens the app on tap.
            // 2. Text record with JSON metadata; its presence marks the NFC
            //    rail and carries the code + name for future richer UX.
            final meta = json.encode({
              'v': 1,
              'code': payload,
              if (boxName != null) 'name': boxName,
              'src': 'nfc',
            });
            await ndef.write(nfc.NdefMessage([
              nfc.NdefRecord.createUri(
                  Uri.parse('treasurebox://box/$payload')),
              nfc.NdefRecord.createText(meta),
            ]));
          }
          if (!completer.isCompleted) completer.complete(_idFromTag(tag));
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(NfcUnavailable('Write failed: $e'));
          }
        }
        await nfc.NfcManager.instance.stopSession();
      },
      onError: (error) async {
        if (!completer.isCompleted) {
          completer.completeError(NfcUnavailable(error.message));
        }
      },
    );
    return completer.future;
  }

  @override
  Future<void> stop() async {
    // Abort the pending wait so the caller's loop can start a FRESH session
    // (a stale one never fires again after the OS reclaims it).
    final waiter = _waiter;
    _waiter = null;
    if (waiter != null && !waiter.isCompleted) {
      waiter.completeError(const NfcUnavailable('Session reset'));
    }
    try {
      await nfc.NfcManager.instance.stopSession();
    } catch (_) {
      // Safe to ignore when no session is active.
    }
  }

  /// Derive a stable id string from the platform tag payload.
  String _idFromTag(nfc.NfcTag tag) {
    final data = tag.data;
    for (final key in ['nfca', 'nfcb', 'nfcf', 'nfcv', 'mifare', 'ndef']) {
      final section = data[key];
      if (section is Map && section['identifier'] is List) {
        final bytes = (section['identifier'] as List).cast<int>();
        return bytes
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join()
            .toUpperCase();
      }
    }
    return tag.handle;
  }

  /// Read the box code from the tag's NDEF records. Prefers the JSON
  /// metadata text record written by [writeTag] (extracting `code`), then a
  /// plain text code, then the `treasurebox://box/...` URI record.
  String? _payloadFromTag(nfc.NfcTag tag) {
    try {
      final ndef = tag.data['ndef'];
      if (ndef is! Map) return null;
      final cached = ndef['cachedMessage'];
      if (cached is! Map) return null;
      final records = cached['records'];
      if (records is! List || records.isEmpty) return null;

      String? plainText;
      String? uriCode;
      for (final record in records) {
        if (record is! Map) continue;
        final payload = record['payload'];
        if (payload is! List) continue;
        final bytes = payload.cast<int>();
        if (bytes.isEmpty) continue;

        final type = record['type'];
        final typeStr = type is List
            ? String.fromCharCodes(type.cast<int>())
            : '';

        if (typeStr == 'T') {
          // Text record: first byte = status (language code length).
          final langLen = bytes[0] & 0x3F;
          if (bytes.length <= 1 + langLen) continue;
          final text = utf8.decode(bytes.sublist(1 + langLen),
              allowMalformed: true);
          // JSON metadata record wins outright.
          if (text.startsWith('{')) {
            try {
              final map = json.decode(text);
              if (map is Map && map['code'] is String) {
                return map['code'] as String;
              }
            } catch (_) {
              // Not JSON after all; treat as plain text below.
            }
          }
          plainText ??= text;
        } else if (typeStr == 'U') {
          // URI record: first byte is the abbreviation code.
          final uri = utf8.decode(bytes.sublist(1), allowMalformed: true);
          final segs = uri.split('/');
          if (segs.isNotEmpty && segs.last.isNotEmpty) {
            uriCode ??= segs.last;
          }
        }
      }
      return plainText ?? uriCode;
    } catch (_) {
      return null;
    }
  }
}

NfcService createNfcService() => MobileNfcService();
