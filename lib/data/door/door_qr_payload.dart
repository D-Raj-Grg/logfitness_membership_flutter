// The text printed (as a QR) on the door display: `LG1.<qr_id>.<8 digits>`.
// Anything else the camera sees -- a poster, a menu, a payment QR -- is not
// ours and is ignored without a word.

/// A well-formed door payload. Validity of the digits is the server's call;
/// this only decides "is it one of ours".
class DoorQrPayload {
  const DoorQrPayload._(this.text);

  /// Canonical text, sent to `member_door_check_in` as-is.
  final String text;

  static final RegExp _pattern = RegExp(r'^LG1\.\d{1,6}\.\d{8}$');

  /// Returns null for every QR that is not a door code. Surrounding
  /// whitespace (some scanners append a newline) is tolerated; case is not --
  /// the prefix is exactly `LG1`.
  static DoorQrPayload? tryParse(String? raw) {
    if (raw == null) return null;
    final String trimmed = raw.trim();
    if (!_pattern.hasMatch(trimmed)) return null;
    return DoorQrPayload._(trimmed);
  }

  @override
  bool operator ==(Object other) =>
      other is DoorQrPayload && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'DoorQrPayload($text)';
}
