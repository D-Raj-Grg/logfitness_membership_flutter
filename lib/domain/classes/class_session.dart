// One upcoming `class_sessions` row with its parent class's name and room.
// Hand-written: tiny, read-only, and the optimistic board needs `copyWith`.

/// Capacity text shown on a card, e.g. `12/20`. Text, never colour alone.
String capacityLabel(int booked, int capacity) => '$booked/$capacity';

class ClassSession {
  const ClassSession({
    required this.id,
    required this.classId,
    required this.className,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.bookedCount,
    this.room,
    this.description,
  });

  final String id;
  final String classId;
  final String className;
  final String? room;
  final String? description;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;

  /// Seats held by `booked` rows only; waitlisted rows do not count.
  final int bookedCount;

  int get spotsLeft => (capacity - bookedCount).clamp(0, capacity);
  bool get isFull => bookedCount >= capacity;
  String get capacityText => capacityLabel(bookedCount, capacity);

  /// 0..1 fill for the capacity meter.
  double get fill =>
      capacity <= 0 ? 0 : (bookedCount / capacity).clamp(0.0, 1.0);

  bool hasStarted(DateTime now) => !startsAt.isAfter(now);

  ClassSession copyWith({int? bookedCount}) => ClassSession(
    id: id,
    classId: classId,
    className: className,
    startsAt: startsAt,
    endsAt: endsAt,
    capacity: capacity,
    bookedCount: bookedCount ?? this.bookedCount,
    room: room,
    description: description,
  );

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    final cls = json['classes'] as Map<String, dynamic>?;
    return ClassSession(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      className: (cls?['name'] as String?) ?? '',
      room: cls?['room'] as String?,
      description: cls?['description'] as String?,
      startsAt: DateTime.parse(json['starts_at'] as String).toUtc(),
      endsAt: DateTime.parse(json['ends_at'] as String).toUtc(),
      capacity: json['capacity'] as int,
      bookedCount: json['booked_count'] as int,
    );
  }
}
