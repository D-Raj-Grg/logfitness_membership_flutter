// What the action button on a session card says and does. Pure, so the whole
// state machine is testable without a widget.
import 'package:logfitness_membership_flutter/domain/classes/class_booking.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking_status.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_session.dart';

enum SessionCardState {
  /// Seats left and no booking: "Book".
  book,

  /// Full and no booking: "Join waitlist".
  joinWaitlist,

  /// Holds a seat: "Booked" with a cancel affordance.
  booked,

  /// In the queue: "On waitlist" with a cancel affordance.
  waitlisted,

  /// Started: nothing to press.
  closed,

  /// A write is in flight for this session.
  busy;

  /// The member can cancel from the card.
  bool get canCancel => this == booked || this == waitlisted;

  /// The member can start a booking from the card.
  bool get canBook => this == book || this == joinWaitlist;
}

SessionCardState sessionCardState({
  required ClassSession session,
  required ClassBooking? liveBooking,
  required bool busy,
  required DateTime now,
}) {
  if (busy) {
    return SessionCardState.busy;
  }
  if (liveBooking != null) {
    return liveBooking.status == ClassBookingStatus.waitlisted
        ? SessionCardState.waitlisted
        : SessionCardState.booked;
  }
  if (session.hasStarted(now)) {
    return SessionCardState.closed;
  }
  return session.isFull ? SessionCardState.joinWaitlist : SessionCardState.book;
}
