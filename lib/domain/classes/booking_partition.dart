import 'package:logfitness_membership_flutter/domain/classes/class_booking.dart';

/// Splits bookings for the Bookings screen.
///
/// Upcoming = still holds a seat or a place in the queue, has not started and
/// was not cancelled by the gym; soonest first. Everything else is past
/// (attended, missed, cancelled, already started); most recent class first.
({List<ClassBooking> upcoming, List<ClassBooking> past}) partitionBookings(
  Iterable<ClassBooking> bookings,
  DateTime now,
) {
  final List<ClassBooking> upcoming = <ClassBooking>[];
  final List<ClassBooking> past = <ClassBooking>[];
  for (final ClassBooking b in bookings) {
    // Optimistic placeholders and cancelled rows never linger in "upcoming".
    if (b.status.isLive && b.isUpcoming(now)) {
      upcoming.add(b);
    } else {
      past.add(b);
    }
  }
  upcoming.sort((a, b) => a.startsAt.compareTo(b.startsAt));
  past.sort((a, b) => b.startsAt.compareTo(a.startsAt));
  return (upcoming: upcoming, past: past);
}
