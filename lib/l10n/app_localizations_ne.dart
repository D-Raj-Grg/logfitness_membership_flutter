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
  String get retry => 'फेरि प्रयास गर्नुहोस्';

  @override
  String get snackRetry => 'फेरि गर्नुहोस्';

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
