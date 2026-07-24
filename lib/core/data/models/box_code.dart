/// How a box code reached the app. Each physical rail wraps the same BOX-N
/// code in its own envelope, so the app can tell a scanned QR from a typed
/// code from an NFC payload.
enum BoxCodeSource { qr, nfc, id }

/// A parsed box code reference: the bare code plus the rail it arrived on.
class BoxCodeRef {
  const BoxCodeRef(this.code, this.source);

  /// The bare human code, e.g. `BOX-1` (envelope stripped, uppercased when
  /// it matches the BOX-N shape; otherwise trimmed as-is for name lookups).
  final String code;

  final BoxCodeSource source;

  @override
  bool operator ==(Object other) =>
      other is BoxCodeRef && other.code == code && other.source == source;

  @override
  int get hashCode => Object.hash(code, source);

  @override
  String toString() => 'BoxCodeRef($code via ${source.name})';
}

/// The QR envelope: printed QR labels encode `TB:BOX-1:QR` so that a scan is
/// distinguishable from a hand-typed code. Any camera app that opens the deep
/// link `/box/TB:BOX-1:QR` therefore stamps the QR rail.
const String qrEnvelopePrefix = 'TB:';
const String qrEnvelopeSuffix = ':QR';

/// Build the string a printed QR label should encode for [code].
String qrEnvelope(String code) => '$qrEnvelopePrefix$code$qrEnvelopeSuffix';

/// The full deep link a printed QR encodes: a `treasurebox://` URI so a
/// camera scan offers to OPEN the app (plain text would just be displayed),
/// still carrying the QR envelope so the rail is stamped correctly.
String qrDeepLink(String code) => 'treasurebox://box/${qrEnvelope(code)}';

/// Parse any raw string a user or rail can present - a bare code (`BOX-1`),
/// a QR envelope (`TB:BOX-1:QR`), a pasted deep link (`.../box/BOX-1`), or
/// junk with whitespace - into a [BoxCodeRef]. Never throws; empty input
/// yields an empty code on the [BoxCodeSource.id] rail.
///
/// [assumeNfc] marks the result as NFC-sourced when the raw string came off
/// a tag payload (the payload itself is a plain code; the rail is known from
/// transport, not the envelope).
BoxCodeRef parseBoxCode(String raw, {bool assumeNfc = false}) {
  var s = raw.trim();

  // A pasted deep link or URL carries the code in its last path segment.
  if (s.contains('/')) {
    s = s.split('/').last.trim();
  }

  var source = assumeNfc ? BoxCodeSource.nfc : BoxCodeSource.id;

  // Strip the QR envelope (case-insensitive). NFC transport wins over the
  // envelope marker: a tag that stores the enveloped string is still NFC.
  final upper = s.toUpperCase();
  if (upper.startsWith(qrEnvelopePrefix) && upper.endsWith(qrEnvelopeSuffix)) {
    s = s.substring(
        qrEnvelopePrefix.length, s.length - qrEnvelopeSuffix.length);
    if (!assumeNfc) source = BoxCodeSource.qr;
  }

  s = s.trim();
  // Canonicalize BOX-N shaped codes; leave anything else (names) untouched.
  if (RegExp(r'^box-?\d+$', caseSensitive: false).hasMatch(s)) {
    final n = s.toUpperCase().replaceAll(RegExp(r'[^0-9]'), '');
    s = 'BOX-$n';
  }

  return BoxCodeRef(s, source);
}
