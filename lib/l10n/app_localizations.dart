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

  /// No description provided for @authErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Card number or PIN is wrong.'**
  String get authErrorInvalid;

  /// No description provided for @authErrorLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Try again in {minutes, plural, =1{1 minute} other{{minutes} minutes}}.'**
  String authErrorLocked(int minutes);

  /// No description provided for @authErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get authErrorOffline;

  /// No description provided for @authErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts from this phone. Please wait a few minutes and try again.'**
  String get authErrorRateLimited;

  /// No description provided for @authErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in right now. Please try again.'**
  String get authErrorUnknown;

  /// No description provided for @authForgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN? Ask the front desk. They can set a new one for you.'**
  String get authForgotPin;

  /// No description provided for @authHidePin.
  ///
  /// In en, this message translates to:
  /// **'Hide PIN'**
  String get authHidePin;

  /// No description provided for @authIdentifierHint.
  ///
  /// In en, this message translates to:
  /// **'0004 or 98XXXXXXXX'**
  String get authIdentifierHint;

  /// No description provided for @authIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Card number or phone'**
  String get authIdentifierLabel;

  /// No description provided for @authNotMemberBody.
  ///
  /// In en, this message translates to:
  /// **'Your membership is no longer active. Please contact the front desk.'**
  String get authNotMemberBody;

  /// No description provided for @authNotMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership not active'**
  String get authNotMemberTitle;

  /// No description provided for @authPinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get authPinLabel;

  /// No description provided for @authShowPin.
  ///
  /// In en, this message translates to:
  /// **'Show PIN'**
  String get authShowPin;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get authSigningIn;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the card number or phone number the front desk gave you.'**
  String get authSubtitle;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'Your membership, in your pocket'**
  String get authTagline;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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

  /// No description provided for @homeActiveOpen.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get homeActiveOpen;

  /// No description provided for @homeAmountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due'**
  String get homeAmountDue;

  /// No description provided for @homeAmountDueHint.
  ///
  /// In en, this message translates to:
  /// **'Pay at the front desk.'**
  String get homeAmountDueHint;

  /// No description provided for @homeBookings.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get homeBookings;

  /// No description provided for @homeBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Classes you\'ve booked'**
  String get homeBookingsSubtitle;

  /// No description provided for @homeCardNo.
  ///
  /// In en, this message translates to:
  /// **'NO. {number}'**
  String homeCardNo(String number);

  /// No description provided for @homeDaysLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day left} other{days left}}'**
  String homeDaysLeftLabel(int count);

  /// No description provided for @homeEndsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get homeEndsLabel;

  /// No description provided for @homeExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get homeExpired;

  /// No description provided for @homeExpiredAgoLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day ago} other{days ago}}'**
  String homeExpiredAgoLabel(int count);

  /// No description provided for @homeExpiredHint.
  ///
  /// In en, this message translates to:
  /// **'Request a renewal and the front desk will get you back in.'**
  String get homeExpiredHint;

  /// No description provided for @homeExpiredPrefix.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get homeExpiredPrefix;

  /// No description provided for @homeExpiringHint.
  ///
  /// In en, this message translates to:
  /// **'Your plan ends soon. Request a renewal so you don\'t miss a day.'**
  String get homeExpiringHint;

  /// No description provided for @homeFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get homeFrozen;

  /// No description provided for @homeFrozenHint.
  ///
  /// In en, this message translates to:
  /// **'Your membership is paused. Ask the front desk to resume it.'**
  String get homeFrozenHint;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeLastDay.
  ///
  /// In en, this message translates to:
  /// **'Last day'**
  String get homeLastDay;

  /// No description provided for @homeLastDayHint.
  ///
  /// In en, this message translates to:
  /// **'Your plan ends today.'**
  String get homeLastDayHint;

  /// No description provided for @homeLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String homeLastUpdated(String time);

  /// No description provided for @homeMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get homeMessages;

  /// No description provided for @homeMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notes from the gym'**
  String get homeMessagesSubtitle;

  /// No description provided for @homeNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get homeNoPlan;

  /// No description provided for @homeNoPlanHint.
  ///
  /// In en, this message translates to:
  /// **'Ask the front desk about a plan.'**
  String get homeNoPlanHint;

  /// No description provided for @homePlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get homePlanLabel;

  /// No description provided for @homeRenewButton.
  ///
  /// In en, this message translates to:
  /// **'Request renewal'**
  String get homeRenewButton;

  /// No description provided for @homeRenewNoMember.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find an active membership on this account. Please contact the front desk.'**
  String get homeRenewNoMember;

  /// No description provided for @homeRenewNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get homeRenewNoteLabel;

  /// No description provided for @homeRenewPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get homeRenewPhoneLabel;

  /// No description provided for @homeRenewRequestedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested at {time}. The front desk will call you.'**
  String homeRenewRequestedAt(String time);

  /// No description provided for @homeRenewRequestedButton.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get homeRenewRequestedButton;

  /// No description provided for @homeRenewRequestedNow.
  ///
  /// In en, this message translates to:
  /// **'Requested just now. The front desk will call you.'**
  String get homeRenewRequestedNow;

  /// No description provided for @homeRenewSend.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get homeRenewSend;

  /// No description provided for @homeRenewSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get homeRenewSending;

  /// No description provided for @homeRenewSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent. The front desk will call you.'**
  String get homeRenewSent;

  /// No description provided for @homeRenewSheetBody.
  ///
  /// In en, this message translates to:
  /// **'The front desk will get your request and call you. You pay at the counter. Nothing is charged here.'**
  String get homeRenewSheetBody;

  /// No description provided for @homeRenewSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Request renewal'**
  String get homeRenewSheetTitle;

  /// No description provided for @homeRenewTooSoon.
  ///
  /// In en, this message translates to:
  /// **'You asked a moment ago. The front desk already has your request.'**
  String get homeRenewTooSoon;

  /// No description provided for @homeSessionsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session left} other{{count} sessions left}}'**
  String homeSessionsLeft(int count);

  /// No description provided for @homeStaleBanner.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh. Showing what we had at {time}.'**
  String homeStaleBanner(String time);

  /// No description provided for @homeStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get homeStatusActive;

  /// No description provided for @homeStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get homeStatusExpired;

  /// No description provided for @homeStatusExpiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get homeStatusExpiring;

  /// No description provided for @homeStatusFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get homeStatusFrozen;

  /// No description provided for @homeStatusNone.
  ///
  /// In en, this message translates to:
  /// **'No plan'**
  String get homeStatusNone;

  /// No description provided for @homeStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get homeStatusUpcoming;

  /// No description provided for @homeUpcomingOn.
  ///
  /// In en, this message translates to:
  /// **'Starts {date}'**
  String homeUpcomingOn(String date);

  /// No description provided for @homeUpcomingSoon.
  ///
  /// In en, this message translates to:
  /// **'Starts soon'**
  String get homeUpcomingSoon;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

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

  /// No description provided for @profileBranch.
  ///
  /// In en, this message translates to:
  /// **'Home branch'**
  String get profileBranch;

  /// No description provided for @profileCardNo.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get profileCardNo;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// No description provided for @profileLanguageNepali.
  ///
  /// In en, this message translates to:
  /// **'नेपाली'**
  String get profileLanguageNepali;

  /// No description provided for @profileMemberCode.
  ///
  /// In en, this message translates to:
  /// **'Member code'**
  String get profileMemberCode;

  /// No description provided for @profileMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get profileMessages;

  /// No description provided for @profileNoCard.
  ///
  /// In en, this message translates to:
  /// **'No card yet'**
  String get profileNoCard;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileSectionAbout;

  /// No description provided for @profileSectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get profileSectionDetails;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need your card number or phone and your PIN to sign in again.'**
  String get profileSignOutConfirmBody;

  /// No description provided for @profileSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutConfirmTitle;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileTheme;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get profileVersion;

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
