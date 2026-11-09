// Result of the `my_card()` RPC: the member's live printed card, if any.
// `{card_no:int|null, card_no_text:text|null, assigned_at:ts|null}`.
class MyCard {
  const MyCard({this.cardNo, this.cardNoText, this.assignedAt});

  const MyCard.none() : this();

  factory MyCard.fromJson(Map<String, dynamic> json) {
    final Object? no = json['card_no'];
    final Object? text = json['card_no_text'];
    final Object? at = json['assigned_at'];
    return MyCard(
      cardNo: no is num ? no.toInt() : null,
      cardNoText: text is String && text.isNotEmpty ? text : null,
      assignedAt: at is String ? DateTime.tryParse(at) : null,
    );
  }

  final int? cardNo;

  /// Zero-padded, e.g. `0004`. Null when the member holds no card.
  final String? cardNoText;
  final DateTime? assignedAt;

  bool get hasCard => cardNoText != null;
}
