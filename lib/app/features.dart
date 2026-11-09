/// Feature switches. Code behind a switch stays compiled and tested; the
/// switch only removes it from the navigation.
library;

/// Classes tab, Bookings screen and the Home "My bookings" tile. Hidden for
/// the first release (decided 2026-11-09).
const bool kClassesEnabled = false;

/// The old "phone shows a QR for a door scanner" screen. Replaced by scanning
/// the door's own rotating QR (`ScanCheckInScreen`); kept for a later scanner.
const bool kShowMemberQr = false;

/// Bottom-navigation tabs, in display order. Router branches and shell
/// destinations are both built from [enabledTabs], so they cannot drift.
enum MemberTab { home, classes, attendance, checkin, payments, profile }

List<MemberTab> get enabledTabs => <MemberTab>[
  MemberTab.home,
  if (kClassesEnabled) MemberTab.classes,
  MemberTab.attendance,
  MemberTab.checkin,
  MemberTab.payments,
  MemberTab.profile,
];
