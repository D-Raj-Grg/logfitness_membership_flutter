// One of the caller's own `class_bookings` rows, flattened with the session's
// time and the class name so a list can render without a second query.
import 'package:logfitness_membership_flutter/domain/classes/class_booking_status.dart';

class ClassBooking {
  const ClassBooking({
    required this.id,
    required this.sessionId,
    required this.status,
    required this.bookedAt,
    required this.className,
    required this.startsAt,
    required this.endsAt,
    this.room,
    this.sessionCancelled = false,
  });

  final String id;
  final String sessionId;
  final ClassBookingStatus status;
  final DateTime bookedAt;
  final String className;
  final String? room;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool sessionCancelled;

  /// Not yet started and not cancelled by the gym.
  bool isUpcoming(DateTime now) => startsAt.isAfter(now) && !sessionCancelled;

  ClassBooking copyWith({ClassBookingStatus? status}) => ClassBooking(
    id: id,
    sessionId: sessionId,
    status: status ?? this.status,
    bookedAt: bookedAt,
    className: className,
    startsAt: startsAt,
    endsAt: endsAt,
    room: room,
    sessionCancelled: sessionCancelled,
  );

  factory ClassBooking.fromJson(Map<String, dynamic> json) {
    final session = json['class_sessions'] as Map<String, dynamic>;
    final cls = session['classes'] as Map<String, dynamic>?;
    return ClassBooking(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      status: ClassBookingStatus.fromDb(json['status'] as String),
      bookedAt: DateTime.parse(json['booked_at'] as String).toUtc(),
      className: (cls?['name'] as String?) ?? '',
      room: cls?['room'] as String?,
      startsAt: DateTime.parse(session['starts_at'] as String).toUtc(),
      endsAt: DateTime.parse(session['ends_at'] as String).toUtc(),
      sessionCancelled: session['status'] == 'cancelled',
    );
  }
}
