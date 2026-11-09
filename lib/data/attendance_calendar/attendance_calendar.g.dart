// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_calendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceDay _$AttendanceDayFromJson(Map<String, dynamic> json) =>
    _AttendanceDay(
      date: const PlainDateConverter().fromJson(json['date'] as String),
      status: $enumDecode(
        _$AttendanceDayStatusEnumMap,
        json['status'],
        unknownValue: AttendanceDayStatus.none,
      ),
      label: json['label'] as String?,
    );

Map<String, dynamic> _$AttendanceDayToJson(_AttendanceDay instance) =>
    <String, dynamic>{
      'date': const PlainDateConverter().toJson(instance.date),
      'status': _$AttendanceDayStatusEnumMap[instance.status]!,
      'label': ?instance.label,
    };

const _$AttendanceDayStatusEnumMap = {
  AttendanceDayStatus.present: 'present',
  AttendanceDayStatus.absent: 'absent',
  AttendanceDayStatus.off: 'off',
  AttendanceDayStatus.holiday: 'holiday',
  AttendanceDayStatus.none: 'none',
};

_AttendanceSummary _$AttendanceSummaryFromJson(Map<String, dynamic> json) =>
    _AttendanceSummary(
      present: (json['present'] as num?)?.toInt() ?? 0,
      absent: (json['absent'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AttendanceSummaryToJson(_AttendanceSummary instance) =>
    <String, dynamic>{'present': instance.present, 'absent': instance.absent};

_AttendanceCalendar _$AttendanceCalendarFromJson(Map<String, dynamic> json) =>
    _AttendanceCalendar(
      days:
          (json['days'] as List<dynamic>?)
              ?.map((e) => AttendanceDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AttendanceDay>[],
      summary: json['summary'] == null
          ? const AttendanceSummary()
          : AttendanceSummary.fromJson(json['summary'] as Map<String, dynamic>),
      today: const PlainDateConverter().fromJson(json['today'] as String),
    );

Map<String, dynamic> _$AttendanceCalendarToJson(_AttendanceCalendar instance) =>
    <String, dynamic>{
      'days': instance.days.map((e) => e.toJson()).toList(),
      'summary': instance.summary.toJson(),
      'today': const PlainDateConverter().toJson(instance.today),
    };
