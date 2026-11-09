// One minted check-in token, as the `mint_qr_token` RPC returns it.
//
// Deliberately carries no expiry instant: expiry is measured from the moment
// the app *received* the token (see `QrRefreshController`), so a skewed phone
// clock or server clock can neither shorten nor lengthen a code's life.

class QrToken {
  const QrToken({required this.token, required this.ttl, this.memberId});

  /// Parses the RPC's `{token, member_id, ttl_seconds, expires_at}` object.
  /// `expires_at` is ignored on purpose (see the file comment).
  factory QrToken.fromJson(Map<String, dynamic> json) {
    return QrToken(
      token: json['token'] as String,
      ttl: Duration(seconds: (json['ttl_seconds'] as num).toInt()),
      memberId: json['member_id'] as String?,
    );
  }

  /// The opaque string encoded into the QR.
  final String token;

  /// How long the server will accept [token], from when it was minted.
  final Duration ttl;

  final String? memberId;
}
