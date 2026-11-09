// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appName => 'LOG Fitness';

  @override
  String attendanceCellSemantics(String date, String status) {
    return '$date, $status';
  }

  @override
  String attendanceDayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String get attendanceEmptyMonth =>
      'यो महिना कुनै उपस्थिति रेकर्ड भएको छैन। चेक-इन गर्न थालेपछि तपाईंको उपस्थिति यहाँ देखिनेछ।';

  @override
  String attendanceHolidayNamed(String name) {
    return 'बिदा: $name';
  }

  @override
  String get attendanceHolidaySheetHint => 'यो दिन जिम बन्द रहन्छ।';

  @override
  String attendanceMonthYear(String month, String year) {
    return '$month $year';
  }

  @override
  String get attendanceNextMonth => 'अर्को महिना';

  @override
  String get attendancePreviousMonth => 'अघिल्लो महिना';

  @override
  String get attendanceStatusAbsent => 'अनुपस्थित';

  @override
  String get attendanceStatusHoliday => 'सार्वजनिक बिदा';

  @override
  String get attendanceStatusNone => 'रेकर्ड छैन';

  @override
  String get attendanceStatusOff => 'बिदाको दिन';

  @override
  String get attendanceStatusPresent => 'उपस्थित';

  @override
  String attendanceSummarySemantics(int present, int absent) {
    return '$present दिन उपस्थित, $absent दिन अनुपस्थित';
  }

  @override
  String get attendanceSummaryTitle => 'महिनाको सारांश';

  @override
  String get authErrorInvalid => 'कार्ड नम्बर वा पिन मिलेन।';

  @override
  String authErrorLocked(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes मिनेट',
      one: '१ मिनेट',
    );
    return 'धेरै पटक प्रयास भयो। $_temp0 पछि फेरि प्रयास गर्नुहोस्।';
  }

  @override
  String get authErrorOffline =>
      'इन्टरनेट छैन। इन्टरनेट जाँचेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get authErrorRateLimited =>
      'यो फोनबाट धेरै प्रयास भयो। केही मिनेट कुरेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get authErrorUnknown =>
      'अहिले साइन इन गर्न सकिएन। कृपया फेरि प्रयास गर्नुहोस्।';

  @override
  String get authForgotPin => 'पिन बिर्सनुभयो? फ्रन्ट डेस्कलाई सोध्नुहोस्।';

  @override
  String get authIdentifierInvalid =>
      'कार्ड नम्बर (१ देखि ४ अंक) वा फोन नम्बर राख्नुहोस्।';

  @override
  String get authIdentifierLabel => 'कार्ड नम्बर वा फोन';

  @override
  String get authNotMemberBody =>
      'तपाईंको सदस्यता अब सक्रिय छैन। कृपया फ्रन्ट डेस्कमा सम्पर्क गर्नुहोस्।';

  @override
  String get authNotMemberTitle => 'सदस्यता सक्रिय छैन';

  @override
  String authPinSemantics(int count) {
    return 'पिन, ६ मध्ये $count अंक भरिएको';
  }

  @override
  String get authSignIn => 'साइन इन';

  @override
  String get authSignOut => 'साइन आउट';

  @override
  String get authSigningIn => 'साइन इन हुँदैछ';

  @override
  String get bookingsCancel => 'बुकिङ रद्द गर्नुहोस्';

  @override
  String bookingsCancelConfirmBody(String name, String when) {
    return '$name, $when';
  }

  @override
  String get bookingsCancelConfirmTitle => 'यो बुकिङ रद्द गर्ने?';

  @override
  String get bookingsEmpty => 'अहिलेसम्म कुनै बुकिङ छैन';

  @override
  String get bookingsEmptyHint => 'कक्षा ट्याबबाट कक्षा बुक गर्नुहोस्।';

  @override
  String get bookingsKeep => 'बुकिङ राख्नुहोस्';

  @override
  String get bookingsNoUpcoming => 'आगामी केही छैन';

  @override
  String get bookingsPast => 'विगत';

  @override
  String get bookingsSessionCancelled => 'जिमले कक्षा रद्द गर्‍यो';

  @override
  String get bookingsStatusAttended => 'उपस्थित भयो';

  @override
  String get bookingsStatusBooked => 'बुक भयो';

  @override
  String get bookingsStatusCancelled => 'रद्द भयो';

  @override
  String get bookingsStatusNoShow => 'अनुपस्थित';

  @override
  String get bookingsStatusWaitlisted => 'प्रतीक्षा सूचीमा';

  @override
  String get bookingsTitle => 'मेरा बुकिङहरू';

  @override
  String get bookingsUpcoming => 'आगामी';

  @override
  String get bookingsWaitlistNote =>
      'सिट खाली भएमा तपाईं आफैँ कक्षामा सारिनुहुनेछ।';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get checkinCameraErrorBody =>
      'क्यामेरा प्रयोग गरिरहेका अन्य एपहरू बन्द गरेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get checkinCameraErrorTitle => 'क्यामेरा सुरु हुन सकेन';

  @override
  String get checkinCameraSemantics =>
      'क्यामेरा दृश्य। ढोकाको स्क्रिनमा रहेको QR कोडतर्फ देखाउनुहोस्।';

  @override
  String get checkinCheckingIn => 'तपाईंको चेक-इन हुँदैछ…';

  @override
  String get checkinClosedBody => 'जिम अहिले बन्द छ।';

  @override
  String get checkinClosedTitle => 'बन्द छ';

  @override
  String checkinDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन बाँकी',
      one: '१ दिन बाँकी',
      zero: 'तपाईंको सदस्यता आज सकिन्छ',
    );
    return '$_temp0';
  }

  @override
  String get checkinDeniedDues => 'तपाईंको बक्यौता तिर्न बाँकी छ।';

  @override
  String checkinDeniedDuesAmount(String amount) {
    return 'तपाईंको $amount बक्यौता छ।';
  }

  @override
  String get checkinDeniedExpired => 'तपाईंको सदस्यता सकिएको छ।';

  @override
  String get checkinDeniedFrozen => 'तपाईंको सदस्यता रोकिएको (फ्रिज) छ।';

  @override
  String get checkinDeniedHint =>
      'कृपया फ्रन्ट डेस्कमा सम्पर्क गर्नुहोस्, उहाँहरूले मिलाइदिनुहुनेछ।';

  @override
  String get checkinDeniedOther => 'यसपटक हामीले तपाईंलाई प्रवेश दिन सकेनौं।';

  @override
  String get checkinDeniedTitle => 'ढोका खुलेन';

  @override
  String get checkinForeignHint =>
      'यो जिमको ढोका कोड होइन। ढोकाको स्क्रिनमा रहेको QR कोड खोज्नुहोस्।';

  @override
  String get checkinInstruction =>
      'ढोकाको स्क्रिनमा रहेको QR कोडतर्फ क्यामेरा देखाउनुहोस्';

  @override
  String get checkinInvalidBody =>
      'त्यो कोडको समय सकिएको छ। स्क्रिन फेरि स्क्यान गर्नुहोस् — यो हरेक ३० सेकेन्डमा बदलिन्छ।';

  @override
  String get checkinInvalidTitle => 'त्यो कोडको समय सकियो';

  @override
  String get checkinNoCameraBody =>
      'यो उपकरणमा प्रयोग गर्न मिल्ने क्यामेरा छैन। कृपया फ्रन्ट डेस्कलाई चेक-इन गरिदिन भन्नुहोस्।';

  @override
  String get checkinNoCameraTitle => 'क्यामेरा भेटिएन';

  @override
  String get checkinOfflineBody =>
      'इन्टरनेट जडान जाँचेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get checkinOfflineTitle => 'इन्टरनेट छैन';

  @override
  String checkinOkGreeting(String name) {
    return 'नमस्ते $name';
  }

  @override
  String get checkinOkTitle => 'ढोका खुल्यो';

  @override
  String get checkinOkWelcomeBack => 'फेरि स्वागत छ — ढोका खुल्यो';

  @override
  String get checkinOpenSettings => 'सेटिङ खोल्नुहोस्';

  @override
  String get checkinPermissionBody =>
      'जिमको ढोकामा रहेको QR कोड स्क्यान गर्न LOG Fitness लाई क्यामेरा चाहिन्छ। यसलाई सेटिङमा गएर खोल्न सकिन्छ।';

  @override
  String get checkinPermissionTitle => 'क्यामेरा अनुमति बन्द छ';

  @override
  String get checkinRateBody =>
      'धेरै पटक प्रयास भयो। कृपया केही मिनेट पर्खनुहोस्।';

  @override
  String get checkinRateTitle => 'अलि पर्खनुहोस्';

  @override
  String get checkinScanAgain => 'फेरि स्क्यान गर्नुहोस्';

  @override
  String get checkinTapToClose => 'बन्द गर्न जहाँसुकै छुनुहोस्';

  @override
  String get checkinTorchOff => 'टर्च निभाउनुहोस्';

  @override
  String get checkinTorchOn => 'टर्च बाल्नुहोस्';

  @override
  String get checkinTryAgain => 'फेरि प्रयास गर्नुहोस्';

  @override
  String get checkinUnknownBody =>
      'तपाईंको चेक-इन गर्न सकिएन। फेरि प्रयास गर्नुहोस्, वा फ्रन्ट डेस्कमा सम्पर्क गर्नुहोस्।';

  @override
  String get checkinUnknownTitle => 'केही गडबड भयो';

  @override
  String get classesBook => 'बुक गर्नुहोस्';

  @override
  String get classesBooked => 'बुक भयो';

  @override
  String classesBookedSnack(String name) {
    return 'तपाईंले $name बुक गर्नुभयो।';
  }

  @override
  String get classesCancel => 'रद्द गर्नुहोस्';

  @override
  String get classesCancelledSnack => 'बुकिङ रद्द गरियो।';

  @override
  String classesCapacitySemantics(int booked, int capacity) {
    return '$capacity मध्ये $booked सिट लिइसकेको';
  }

  @override
  String get classesClosed => 'बन्द';

  @override
  String get classesDaySelectorLabel => 'दिन छान्नुहोस्';

  @override
  String get classesFull => 'भरिएको';

  @override
  String get classesJoinWaitlist => 'प्रतीक्षा सूचीमा जोडिनुहोस्';

  @override
  String get classesMyBookings => 'मेरा बुकिङहरू';

  @override
  String get classesNoClasses => 'यो दिन कुनै कक्षा छैन';

  @override
  String get classesNoClassesHint =>
      'अर्को दिन छान्नुहोस्, वा पछि फेरि हेर्नुहोस्।';

  @override
  String get classesOnWaitlist => 'प्रतीक्षा सूचीमा';

  @override
  String classesRoom(String room) {
    return 'कोठा $room';
  }

  @override
  String classesSpotsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सिट बाँकी',
      one: '१ सिट बाँकी',
    );
    return '$_temp0';
  }

  @override
  String get classesToday => 'आज';

  @override
  String get classesUpdating => 'अपडेट हुँदैछ';

  @override
  String classesWaitlistedSnack(String name) {
    return 'तपाईं $name को प्रतीक्षा सूचीमा हुनुहुन्छ।';
  }

  @override
  String classesWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'सोम',
      'tue': 'मङ्गल',
      'wed': 'बुध',
      'thu': 'बिहि',
      'fri': 'शुक्र',
      'sat': 'शनि',
      'sun': 'आइत',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get comingSoon => 'छिट्टै आउँदैछ';

  @override
  String get emptyDefault => 'यहाँ अहिलेसम्म केही छैन।';

  @override
  String get failureDuplicate => 'पहिले नै छ';

  @override
  String get failureInvalid => 'यो मान्य हुँदैन';

  @override
  String get failureNotFound => 'फेला परेन';

  @override
  String get failureOffline => 'इन्टरनेट छैन';

  @override
  String get failureRefused => 'अस्वीकृत';

  @override
  String get failureSignedOut => 'साइन आउट भयो';

  @override
  String get failureUnknown => 'यो काम गरेन';

  @override
  String get homeActiveOpen => 'सक्रिय';

  @override
  String get homeAmountDue => 'तिर्नुपर्ने रकम';

  @override
  String get homeAmountDueHint => 'फ्रन्ट डेस्कमा तिर्नुहोस्।';

  @override
  String get homeBookings => 'मेरा बुकिङ';

  @override
  String get homeBookingsSubtitle => 'तपाईंले बुक गरेका कक्षा';

  @override
  String homeCardNo(String number) {
    return 'नं. $number';
  }

  @override
  String homeDaysLeftLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दिन बाँकी',
      one: 'दिन बाँकी',
    );
    return '$_temp0';
  }

  @override
  String get homeEndsLabel => 'सकिने मिति';

  @override
  String homeExpiredAgoLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दिन अघि',
      one: 'दिन अघि',
    );
    return '$_temp0';
  }

  @override
  String get homeExpiredHint =>
      'नवीकरणको अनुरोध गर्नुहोस्, फ्रन्ट डेस्कले तपाईंलाई फेरि सुचारु गरिदिनुहुन्छ।';

  @override
  String get homeExpiringHint =>
      'तपाईंको योजना छिट्टै सकिँदैछ। एक दिन पनि नछुटोस् भनेर नवीकरणको अनुरोध गर्नुहोस्।';

  @override
  String get homeFrozen => 'रोकिएको';

  @override
  String get homeFrozenHint =>
      'तपाईंको सदस्यता रोकिएको छ। फेरि चालु गर्न फ्रन्ट डेस्कलाई भन्नुहोस्।';

  @override
  String homeGreeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get homeLastDay => 'अन्तिम दिन';

  @override
  String get homeLastDayHint => 'तपाईंको योजना आज सकिँदैछ।';

  @override
  String homeLastUpdated(String time) {
    return '$time मा अद्यावधिक';
  }

  @override
  String get homeMembershipEnded => 'सदस्यता सकियो';

  @override
  String get homeMessages => 'सन्देशहरू';

  @override
  String get homeMessagesSubtitle => 'जिमबाट आएका सूचना';

  @override
  String get homeNoPlan => 'सक्रिय योजना छैन';

  @override
  String get homeNoPlanHint => 'योजनाको बारेमा फ्रन्ट डेस्कलाई सोध्नुहोस्।';

  @override
  String get homePlanLabel => 'योजना';

  @override
  String get homeRenewButton => 'नवीकरणको अनुरोध';

  @override
  String get homeRenewNoMember =>
      'यो खातामा सक्रिय सदस्यता भेटिएन। कृपया फ्रन्ट डेस्कमा सम्पर्क गर्नुहोस्।';

  @override
  String get homeRenewNoteLabel => 'टिप्पणी (ऐच्छिक)';

  @override
  String get homeRenewPhoneLabel => 'फोन (ऐच्छिक)';

  @override
  String homeRenewRequestedAt(String time) {
    return '$time मा अनुरोध गरियो। फ्रन्ट डेस्कले तपाईंलाई फोन गर्नुहुन्छ।';
  }

  @override
  String get homeRenewRequestedButton => 'अनुरोध पठाइयो';

  @override
  String get homeRenewRequestedNow =>
      'अहिले नै अनुरोध गरियो। फ्रन्ट डेस्कले तपाईंलाई फोन गर्नुहुन्छ।';

  @override
  String homeRenewRequestedOn(String date, String time) {
    return '$date $time मा अनुरोध गरियो। फ्रन्ट डेस्कले तपाईंलाई फोन गर्नुहुन्छ।';
  }

  @override
  String get homeRenewSend => 'अनुरोध पठाउनुहोस्';

  @override
  String get homeRenewSending => 'पठाउँदैछ';

  @override
  String get homeRenewSent =>
      'अनुरोध पठाइयो। फ्रन्ट डेस्कले तपाईंलाई फोन गर्नुहुन्छ।';

  @override
  String get homeRenewSheetBody =>
      'फ्रन्ट डेस्कले तपाईंको अनुरोध पाउँछ र फोन गर्छ। रकम काउन्टरमै तिर्नुहुन्छ। यहाँ केही पनि काटिँदैन।';

  @override
  String get homeRenewSheetTitle => 'नवीकरणको अनुरोध';

  @override
  String get homeRenewTooSoon =>
      'तपाईंले भर्खरै अनुरोध गर्नुभएको छ। फ्रन्ट डेस्कसँग तपाईंको अनुरोध पुगिसकेको छ।';

  @override
  String homeSessionsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सत्र बाँकी',
      one: '१ सत्र बाँकी',
    );
    return '$_temp0';
  }

  @override
  String homeStaleBanner(String time) {
    return 'नयाँ जानकारी ल्याउन सकिएन। $time को जानकारी देखाइएको छ।';
  }

  @override
  String get homeStatusActive => 'सक्रिय';

  @override
  String get homeStatusExpired => 'म्याद सकियो';

  @override
  String get homeStatusExpiring => 'छिट्टै सकिँदैछ';

  @override
  String get homeStatusFrozen => 'रोकिएको';

  @override
  String get homeStatusNone => 'योजना छैन';

  @override
  String get homeStatusUpcoming => 'आउँदै';

  @override
  String homeUpcomingOn(String date) {
    return '$date देखि सुरु';
  }

  @override
  String get homeUpcomingSoon => 'छिट्टै सुरु हुन्छ';

  @override
  String get loading => 'लोड हुँदैछ';

  @override
  String get messagesChannelEmail => 'इमेल';

  @override
  String get messagesChannelSms => 'एसएमएस';

  @override
  String get messagesChannelViber => 'भाइबर';

  @override
  String get messagesEmpty => 'अहिलेसम्म कुनै सन्देश छैन';

  @override
  String get messagesEmptyHint => 'जिमबाट आएका सन्देशहरू यहाँ देखिनेछन्।';

  @override
  String get messagesEventAnnouncement => 'सूचना';

  @override
  String get messagesEventBirthdayGreeting => 'जन्मदिनको शुभकामना';

  @override
  String get messagesEventCustomMessage => 'जिमबाट सन्देश';

  @override
  String get messagesEventDuesCleared => 'बाँकी रकम चुक्ता';

  @override
  String get messagesEventDuesReminder => 'बाँकी रकम सम्झना';

  @override
  String get messagesEventMemberWelcome => 'स्वागत छ';

  @override
  String get messagesEventMembershipRenewed => 'सदस्यता नवीकरण भयो';

  @override
  String get messagesEventOther => 'जिमबाट सन्देश';

  @override
  String get messagesEventPaymentReceived => 'भुक्तानी रसिद';

  @override
  String get messagesEventRenewalReminder => 'नवीकरण सम्झना';

  @override
  String messagesHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घण्टा अघि',
      one: '१ घण्टा अघि',
    );
    return '$_temp0';
  }

  @override
  String get messagesJustNow => 'अहिले भर्खरै';

  @override
  String get messagesMarkAllRead => 'सबै पढिसकेको चिन्ह लगाउनुहोस्';

  @override
  String messagesMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनेट अघि',
      one: '१ मिनेट अघि',
    );
    return '$_temp0';
  }

  @override
  String get messagesTitle => 'सन्देशहरू';

  @override
  String get messagesUnread => 'नपढिएको';

  @override
  String get offline => 'तपाईं अफलाइन हुनुहुन्छ';

  @override
  String get ok => 'ठीक छ';

  @override
  String get paymentsAllSettled => 'सबै चुक्ता भएको छ - कुनै बाँकी छैन';

  @override
  String get paymentsAmountDue => 'तिर्न बाँकी रकम';

  @override
  String get paymentsDiscount => 'छुट';

  @override
  String get paymentsDue => 'बाँकी';

  @override
  String get paymentsEmptyInvoices =>
      'अहिलेसम्म कुनै बिल छैन। सदस्यता लिँदा वा नवीकरण गर्दा यहाँ देखिन्छ।';

  @override
  String get paymentsEmptyPayments =>
      'अहिलेसम्म कुनै भुक्तानी छैन। फ्रन्ट डेस्कमा गरेको भुक्तानी यहाँ देखिन्छ।';

  @override
  String paymentsIssuedOn(String date) {
    return 'जारी मिति $date';
  }

  @override
  String get paymentsKindPayment => 'भुक्तानी';

  @override
  String get paymentsKindRefund => 'फिर्ता';

  @override
  String get paymentsKindReversal => 'उल्टाइएको';

  @override
  String get paymentsMethodBank => 'बैंक ट्रान्सफर';

  @override
  String get paymentsMethodCard => 'कार्ड';

  @override
  String get paymentsMethodCash => 'नगद';

  @override
  String get paymentsMethodEsewa => 'eSewa';

  @override
  String get paymentsMethodFonepay => 'Fonepay';

  @override
  String get paymentsMethodKhalti => 'Khalti';

  @override
  String paymentsMethodOnDate(String method, String date) {
    return '$method - $date';
  }

  @override
  String paymentsMonthYear(String month, String year) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'जनवरी',
      'm2': 'फेब्रुअरी',
      'm3': 'मार्च',
      'm4': 'अप्रिल',
      'm5': 'मे',
      'm6': 'जुन',
      'm7': 'जुलाई',
      'm8': 'अगस्ट',
      'm9': 'सेप्टेम्बर',
      'm10': 'अक्टोबर',
      'm11': 'नोभेम्बर',
      'm12': 'डिसेम्बर',
      'other': '',
    });
    return '$_temp0 $year';
  }

  @override
  String get paymentsOnThisInvoice => 'यो बिलमा गरिएको भुक्तानी';

  @override
  String get paymentsPaid => 'तिरेको';

  @override
  String paymentsPaidAndDue(String paid, String due) {
    return 'तिरेको $paid - बाँकी $due';
  }

  @override
  String paymentsPaidOnly(String amount) {
    return 'तिरेको $amount';
  }

  @override
  String get paymentsPayAtDesk => 'कृपया फ्रन्ट डेस्कमा भुक्तानी गर्नुहोस्।';

  @override
  String paymentsReason(String reason) {
    return 'कारण: $reason';
  }

  @override
  String get paymentsStatusPaid => 'भुक्तानी भयो';

  @override
  String get paymentsStatusPartial => 'आंशिक भुक्तानी';

  @override
  String get paymentsStatusUnpaid => 'तिर्न बाँकी';

  @override
  String get paymentsStatusVoid => 'रद्द';

  @override
  String get paymentsSubtotal => 'उप-जम्मा';

  @override
  String get paymentsTabInvoices => 'बिलहरू';

  @override
  String get paymentsTabPayments => 'भुक्तानीहरू';

  @override
  String get paymentsTotal => 'जम्मा';

  @override
  String get paymentsTotalPaid => 'कुल भुक्तानी';

  @override
  String get profileBranch => 'मुख्य शाखा';

  @override
  String get profileCardNo => 'कार्ड नम्बर';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageNepali => 'नेपाली';

  @override
  String get profileMemberCode => 'सदस्य कोड';

  @override
  String get profileMessages => 'सन्देशहरू';

  @override
  String get profileNoCard => 'कार्ड अझै छैन';

  @override
  String get profilePhone => 'फोन';

  @override
  String get profileSectionAbout => 'बारेमा';

  @override
  String get profileSectionDetails => 'तपाईंको विवरण';

  @override
  String get profileSectionPreferences => 'रोजाइ';

  @override
  String get profileSignOut => 'साइन आउट';

  @override
  String get profileSignOutConfirmBody =>
      'फेरि साइन इन गर्न कार्ड नम्बर वा फोन र पिन चाहिन्छ।';

  @override
  String get profileSignOutConfirmTitle => 'साइन आउट गर्ने?';

  @override
  String get profileTheme => 'रूपरङ';

  @override
  String get profileThemeDark => 'अँध्यारो';

  @override
  String get profileThemeLight => 'उज्यालो';

  @override
  String get profileThemeSystem => 'फोन अनुसार';

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String get profileVersion => 'एपको संस्करण';

  @override
  String get qrCheckAgain => 'फेरि जाँच गर्नुहोस्';

  @override
  String get qrExpired => 'कोडको समय सकियो';

  @override
  String get qrHeadline => 'ढोकामा यो देखाउनुहोस्';

  @override
  String get qrLoading => 'तपाईंको कोड ल्याउँदै…';

  @override
  String qrMemberCode(String code) {
    return 'सदस्य $code';
  }

  @override
  String get qrNotEligibleBody =>
      'फ्रन्ट डेस्कले यो समस्या समाधान नगरेसम्म ढोकाले यो कोड स्वीकार गर्दैन। कृपया फ्रन्ट डेस्कमा भेट्नुहोस्, हामी तपाईंलाई भित्र पठाउँछौं।';

  @override
  String get qrNotEligibleTitle => 'अहिले चेक-इन गर्न मिल्दैन';

  @override
  String get qrReconnecting => 'फेरि जडान हुँदैछ…';

  @override
  String get qrReconnectingHint =>
      'चिन्ता नलिनुहोस्। हामी प्रयास गरिरहन्छौं, जडान फर्किनेबित्तिकै नयाँ कोड देखिनेछ।';

  @override
  String qrSecondsLeft(int seconds) {
    return '$seconds सेकेन्डमा नवीकरण हुन्छ';
  }

  @override
  String qrSemanticsLabel(String name) {
    return '$name को चेक-इन QR कोड';
  }

  @override
  String get qrSemanticsLabelNoName => 'चेक-इन QR कोड';

  @override
  String get qrSubtitle => 'तपाईंको कोड आफैँ नवीकरण हुन्छ।';

  @override
  String get retry => 'फेरि प्रयास गर्नुहोस्';

  @override
  String get snackRetry => 'फेरि गर्नुहोस्';

  @override
  String get tabAttendance => 'उपस्थिति';

  @override
  String get tabCheckin => 'चेक-इन';

  @override
  String get tabClasses => 'कक्षा';

  @override
  String get tabHome => 'गृह';

  @override
  String get tabPayments => 'भुक्तानी';

  @override
  String get tabProfile => 'प्रोफाइल';
}
