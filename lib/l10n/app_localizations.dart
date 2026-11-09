import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// Store name of the app.
  ///
  /// In en, this message translates to:
  /// **'LOG Fitness'**
  String get appName;

  /// No description provided for @bookingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get bookingsCancel;

  /// No description provided for @bookingsCancelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name}, {when}'**
  String bookingsCancelConfirmBody(String name, String when);

  /// No description provided for @bookingsCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking?'**
  String get bookingsCancelConfirmTitle;

  /// No description provided for @bookingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get bookingsEmpty;

  /// No description provided for @bookingsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Book a class from the Classes tab.'**
  String get bookingsEmptyHint;

  /// No description provided for @bookingsKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get bookingsKeep;

  /// No description provided for @bookingsNoUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Nothing coming up'**
  String get bookingsNoUpcoming;

  /// No description provided for @bookingsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get bookingsPast;

  /// No description provided for @bookingsSessionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Class cancelled by the gym'**
  String get bookingsSessionCancelled;

  /// No description provided for @bookingsStatusAttended.
  ///
  /// In en, this message translates to:
  /// **'Attended'**
  String get bookingsStatusAttended;

  /// No description provided for @bookingsStatusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get bookingsStatusBooked;

  /// No description provided for @bookingsStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingsStatusCancelled;

  /// No description provided for @bookingsStatusNoShow.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get bookingsStatusNoShow;

  /// No description provided for @bookingsStatusWaitlisted.
  ///
  /// In en, this message translates to:
  /// **'On waitlist'**
  String get bookingsStatusWaitlisted;

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get bookingsTitle;

  /// No description provided for @bookingsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get bookingsUpcoming;

  /// No description provided for @bookingsWaitlistNote.
  ///
  /// In en, this message translates to:
  /// **'You\'ll move into the class automatically if a spot opens.'**
  String get bookingsWaitlistNote;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @classesBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get classesBook;

  /// No description provided for @classesBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get classesBooked;

  /// No description provided for @classesBookedSnack.
  ///
  /// In en, this message translates to:
  /// **'You\'re booked in for {name}.'**
  String classesBookedSnack(String name);

  /// No description provided for @classesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get classesCancel;

  /// No description provided for @classesCancelledSnack.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled.'**
  String get classesCancelledSnack;

  /// No description provided for @classesCapacitySemantics.
  ///
  /// In en, this message translates to:
  /// **'{booked} of {capacity} places taken'**
  String classesCapacitySemantics(int booked, int capacity);

  /// No description provided for @classesClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get classesClosed;

  /// No description provided for @classesDaySelectorLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a day'**
  String get classesDaySelectorLabel;

  /// No description provided for @classesFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get classesFull;

  /// No description provided for @classesJoinWaitlist.
  ///
  /// In en, this message translates to:
  /// **'Join waitlist'**
  String get classesJoinWaitlist;

  /// No description provided for @classesMyBookings.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get classesMyBookings;

  /// No description provided for @classesNoClasses.
  ///
  /// In en, this message translates to:
  /// **'No classes this day'**
  String get classesNoClasses;

  /// No description provided for @classesNoClassesHint.
  ///
  /// In en, this message translates to:
  /// **'Pick another day, or check back later.'**
  String get classesNoClassesHint;

  /// No description provided for @classesOnWaitlist.
  ///
  /// In en, this message translates to:
  /// **'On waitlist'**
  String get classesOnWaitlist;

  /// No description provided for @classesRoom.
  ///
  /// In en, this message translates to:
  /// **'Room {room}'**
  String classesRoom(String room);

  /// No description provided for @classesSpotsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 spot left} other{{count} spots left}}'**
  String classesSpotsLeft(int count);

  /// No description provided for @classesToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get classesToday;

  /// No description provided for @classesUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get classesUpdating;

  /// No description provided for @classesWaitlistedSnack.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the waitlist for {name}.'**
  String classesWaitlistedSnack(String name);

  /// No description provided for @classesWeekdayShort.
  ///
  /// In en, this message translates to:
  /// **'{day, select, mon{Mon} tue{Tue} wed{Wed} thu{Thu} fri{Fri} sat{Sat} sun{Sun} other{}}'**
  String classesWeekdayShort(String day);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @emptyDefault.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get emptyDefault;

  /// No description provided for @failureDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Already exists'**
  String get failureDuplicate;

  /// No description provided for @failureInvalid.
  ///
  /// In en, this message translates to:
  /// **'That would not be valid'**
  String get failureInvalid;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get failureNotFound;

  /// No description provided for @failureOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get failureOffline;

  /// No description provided for @failureRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get failureRefused;

  /// No description provided for @failureSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get failureSignedOut;

  /// No description provided for @failureUnknown.
  ///
  /// In en, this message translates to:
  /// **'That did not work'**
  String get failureUnknown;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @messagesChannelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get messagesChannelEmail;

  /// No description provided for @messagesChannelSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get messagesChannelSms;

  /// No description provided for @messagesChannelViber.
  ///
  /// In en, this message translates to:
  /// **'Viber'**
  String get messagesChannelViber;

  /// No description provided for @messagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messagesEmpty;

  /// No description provided for @messagesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Messages from the gym will appear here.'**
  String get messagesEmptyHint;

  /// No description provided for @messagesEventAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get messagesEventAnnouncement;

  /// No description provided for @messagesEventBirthdayGreeting.
  ///
  /// In en, this message translates to:
  /// **'Birthday greeting'**
  String get messagesEventBirthdayGreeting;

  /// No description provided for @messagesEventCustomMessage.
  ///
  /// In en, this message translates to:
  /// **'Message from the gym'**
  String get messagesEventCustomMessage;

  /// No description provided for @messagesEventDuesCleared.
  ///
  /// In en, this message translates to:
  /// **'Balance cleared'**
  String get messagesEventDuesCleared;

  /// No description provided for @messagesEventDuesReminder.
  ///
  /// In en, this message translates to:
  /// **'Dues reminder'**
  String get messagesEventDuesReminder;

  /// No description provided for @messagesEventMemberWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get messagesEventMemberWelcome;

  /// No description provided for @messagesEventMembershipRenewed.
  ///
  /// In en, this message translates to:
  /// **'Membership renewed'**
  String get messagesEventMembershipRenewed;

  /// No description provided for @messagesEventOther.
  ///
  /// In en, this message translates to:
  /// **'Message from the gym'**
  String get messagesEventOther;

  /// No description provided for @messagesEventPaymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment receipt'**
  String get messagesEventPaymentReceived;

  /// No description provided for @messagesEventRenewalReminder.
  ///
  /// In en, this message translates to:
  /// **'Renewal reminder'**
  String get messagesEventRenewalReminder;

  /// No description provided for @messagesHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String messagesHoursAgo(int count);

  /// No description provided for @messagesJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get messagesJustNow;

  /// No description provided for @messagesMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get messagesMarkAllRead;

  /// No description provided for @messagesMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String messagesMinutesAgo(int count);

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get messagesUnread;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offline;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @snackRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get snackRetry;

  /// No description provided for @tabCheckin.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get tabCheckin;

  /// No description provided for @tabClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get tabClasses;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get tabPayments;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
