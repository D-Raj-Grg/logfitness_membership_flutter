// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_calendar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceDay {

@PlainDateConverter() DateTime get date;@JsonKey(unknownEnumValue: AttendanceDayStatus.none) AttendanceDayStatus get status;// Holiday name when [status] is holiday, otherwise null.
 String? get label;
/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceDayCopyWith<AttendanceDay> get copyWith => _$AttendanceDayCopyWithImpl<AttendanceDay>(this as AttendanceDay, _$identity);

  /// Serializes this AttendanceDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceDay&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,status,label);

@override
String toString() {
  return 'AttendanceDay(date: $date, status: $status, label: $label)';
}


}

/// @nodoc
abstract mixin class $AttendanceDayCopyWith<$Res>  {
  factory $AttendanceDayCopyWith(AttendanceDay value, $Res Function(AttendanceDay) _then) = _$AttendanceDayCopyWithImpl;
@useResult
$Res call({
@PlainDateConverter() DateTime date,@JsonKey(unknownEnumValue: AttendanceDayStatus.none) AttendanceDayStatus status, String? label
});




}
/// @nodoc
class _$AttendanceDayCopyWithImpl<$Res>
    implements $AttendanceDayCopyWith<$Res> {
  _$AttendanceDayCopyWithImpl(this._self, this._then);

  final AttendanceDay _self;
  final $Res Function(AttendanceDay) _then;

/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? status = null,Object? label = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceDayStatus,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceDay].
extension AttendanceDayPatterns on AttendanceDay {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceDay value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceDay():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceDay value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@PlainDateConverter()  DateTime date, @JsonKey(unknownEnumValue: AttendanceDayStatus.none)  AttendanceDayStatus status,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
return $default(_that.date,_that.status,_that.label);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@PlainDateConverter()  DateTime date, @JsonKey(unknownEnumValue: AttendanceDayStatus.none)  AttendanceDayStatus status,  String? label)  $default,) {final _that = this;
switch (_that) {
case _AttendanceDay():
return $default(_that.date,_that.status,_that.label);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@PlainDateConverter()  DateTime date, @JsonKey(unknownEnumValue: AttendanceDayStatus.none)  AttendanceDayStatus status,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
return $default(_that.date,_that.status,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceDay implements AttendanceDay {
  const _AttendanceDay({@PlainDateConverter() required this.date, @JsonKey(unknownEnumValue: AttendanceDayStatus.none) required this.status, this.label});
  factory _AttendanceDay.fromJson(Map<String, dynamic> json) => _$AttendanceDayFromJson(json);

@override@PlainDateConverter() final  DateTime date;
@override@JsonKey(unknownEnumValue: AttendanceDayStatus.none) final  AttendanceDayStatus status;
// Holiday name when [status] is holiday, otherwise null.
@override final  String? label;

/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceDayCopyWith<_AttendanceDay> get copyWith => __$AttendanceDayCopyWithImpl<_AttendanceDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceDay&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,status,label);

@override
String toString() {
  return 'AttendanceDay(date: $date, status: $status, label: $label)';
}


}

/// @nodoc
abstract mixin class _$AttendanceDayCopyWith<$Res> implements $AttendanceDayCopyWith<$Res> {
  factory _$AttendanceDayCopyWith(_AttendanceDay value, $Res Function(_AttendanceDay) _then) = __$AttendanceDayCopyWithImpl;
@override @useResult
$Res call({
@PlainDateConverter() DateTime date,@JsonKey(unknownEnumValue: AttendanceDayStatus.none) AttendanceDayStatus status, String? label
});




}
/// @nodoc
class __$AttendanceDayCopyWithImpl<$Res>
    implements _$AttendanceDayCopyWith<$Res> {
  __$AttendanceDayCopyWithImpl(this._self, this._then);

  final _AttendanceDay _self;
  final $Res Function(_AttendanceDay) _then;

/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? status = null,Object? label = freezed,}) {
  return _then(_AttendanceDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceDayStatus,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AttendanceSummary {

 int get present; int get absent;
/// Create a copy of AttendanceSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceSummaryCopyWith<AttendanceSummary> get copyWith => _$AttendanceSummaryCopyWithImpl<AttendanceSummary>(this as AttendanceSummary, _$identity);

  /// Serializes this AttendanceSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceSummary&&(identical(other.present, present) || other.present == present)&&(identical(other.absent, absent) || other.absent == absent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,present,absent);

@override
String toString() {
  return 'AttendanceSummary(present: $present, absent: $absent)';
}


}

/// @nodoc
abstract mixin class $AttendanceSummaryCopyWith<$Res>  {
  factory $AttendanceSummaryCopyWith(AttendanceSummary value, $Res Function(AttendanceSummary) _then) = _$AttendanceSummaryCopyWithImpl;
@useResult
$Res call({
 int present, int absent
});




}
/// @nodoc
class _$AttendanceSummaryCopyWithImpl<$Res>
    implements $AttendanceSummaryCopyWith<$Res> {
  _$AttendanceSummaryCopyWithImpl(this._self, this._then);

  final AttendanceSummary _self;
  final $Res Function(AttendanceSummary) _then;

/// Create a copy of AttendanceSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? present = null,Object? absent = null,}) {
  return _then(_self.copyWith(
present: null == present ? _self.present : present // ignore: cast_nullable_to_non_nullable
as int,absent: null == absent ? _self.absent : absent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceSummary].
extension AttendanceSummaryPatterns on AttendanceSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceSummary value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int present,  int absent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceSummary() when $default != null:
return $default(_that.present,_that.absent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int present,  int absent)  $default,) {final _that = this;
switch (_that) {
case _AttendanceSummary():
return $default(_that.present,_that.absent);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int present,  int absent)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceSummary() when $default != null:
return $default(_that.present,_that.absent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceSummary implements AttendanceSummary {
  const _AttendanceSummary({this.present = 0, this.absent = 0});
  factory _AttendanceSummary.fromJson(Map<String, dynamic> json) => _$AttendanceSummaryFromJson(json);

@override@JsonKey() final  int present;
@override@JsonKey() final  int absent;

/// Create a copy of AttendanceSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceSummaryCopyWith<_AttendanceSummary> get copyWith => __$AttendanceSummaryCopyWithImpl<_AttendanceSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceSummary&&(identical(other.present, present) || other.present == present)&&(identical(other.absent, absent) || other.absent == absent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,present,absent);

@override
String toString() {
  return 'AttendanceSummary(present: $present, absent: $absent)';
}


}

/// @nodoc
abstract mixin class _$AttendanceSummaryCopyWith<$Res> implements $AttendanceSummaryCopyWith<$Res> {
  factory _$AttendanceSummaryCopyWith(_AttendanceSummary value, $Res Function(_AttendanceSummary) _then) = __$AttendanceSummaryCopyWithImpl;
@override @useResult
$Res call({
 int present, int absent
});




}
/// @nodoc
class __$AttendanceSummaryCopyWithImpl<$Res>
    implements _$AttendanceSummaryCopyWith<$Res> {
  __$AttendanceSummaryCopyWithImpl(this._self, this._then);

  final _AttendanceSummary _self;
  final $Res Function(_AttendanceSummary) _then;

/// Create a copy of AttendanceSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? present = null,Object? absent = null,}) {
  return _then(_AttendanceSummary(
present: null == present ? _self.present : present // ignore: cast_nullable_to_non_nullable
as int,absent: null == absent ? _self.absent : absent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AttendanceCalendar {

 List<AttendanceDay> get days; AttendanceSummary get summary;// The org-timezone "today" the server used to classify the days.
@PlainDateConverter() DateTime get today;
/// Create a copy of AttendanceCalendar
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceCalendarCopyWith<AttendanceCalendar> get copyWith => _$AttendanceCalendarCopyWithImpl<AttendanceCalendar>(this as AttendanceCalendar, _$identity);

  /// Serializes this AttendanceCalendar to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceCalendar&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.today, today) || other.today == today));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(days),summary,today);

@override
String toString() {
  return 'AttendanceCalendar(days: $days, summary: $summary, today: $today)';
}


}

/// @nodoc
abstract mixin class $AttendanceCalendarCopyWith<$Res>  {
  factory $AttendanceCalendarCopyWith(AttendanceCalendar value, $Res Function(AttendanceCalendar) _then) = _$AttendanceCalendarCopyWithImpl;
@useResult
$Res call({
 List<AttendanceDay> days, AttendanceSummary summary,@PlainDateConverter() DateTime today
});


$AttendanceSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$AttendanceCalendarCopyWithImpl<$Res>
    implements $AttendanceCalendarCopyWith<$Res> {
  _$AttendanceCalendarCopyWithImpl(this._self, this._then);

  final AttendanceCalendar _self;
  final $Res Function(AttendanceCalendar) _then;

/// Create a copy of AttendanceCalendar
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? days = null,Object? summary = null,Object? today = null,}) {
  return _then(_self.copyWith(
days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<AttendanceDay>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as AttendanceSummary,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of AttendanceCalendar
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceSummaryCopyWith<$Res> get summary {
  
  return $AttendanceSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceCalendar].
extension AttendanceCalendarPatterns on AttendanceCalendar {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceCalendar value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceCalendar() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceCalendar value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceCalendar():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceCalendar value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceCalendar() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AttendanceDay> days,  AttendanceSummary summary, @PlainDateConverter()  DateTime today)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceCalendar() when $default != null:
return $default(_that.days,_that.summary,_that.today);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AttendanceDay> days,  AttendanceSummary summary, @PlainDateConverter()  DateTime today)  $default,) {final _that = this;
switch (_that) {
case _AttendanceCalendar():
return $default(_that.days,_that.summary,_that.today);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AttendanceDay> days,  AttendanceSummary summary, @PlainDateConverter()  DateTime today)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceCalendar() when $default != null:
return $default(_that.days,_that.summary,_that.today);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceCalendar implements AttendanceCalendar {
  const _AttendanceCalendar({final  List<AttendanceDay> days = const <AttendanceDay>[], this.summary = const AttendanceSummary(), @PlainDateConverter() required this.today}): _days = days;
  factory _AttendanceCalendar.fromJson(Map<String, dynamic> json) => _$AttendanceCalendarFromJson(json);

 final  List<AttendanceDay> _days;
@override@JsonKey() List<AttendanceDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override@JsonKey() final  AttendanceSummary summary;
// The org-timezone "today" the server used to classify the days.
@override@PlainDateConverter() final  DateTime today;

/// Create a copy of AttendanceCalendar
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceCalendarCopyWith<_AttendanceCalendar> get copyWith => __$AttendanceCalendarCopyWithImpl<_AttendanceCalendar>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceCalendarToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceCalendar&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.today, today) || other.today == today));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_days),summary,today);

@override
String toString() {
  return 'AttendanceCalendar(days: $days, summary: $summary, today: $today)';
}


}

/// @nodoc
abstract mixin class _$AttendanceCalendarCopyWith<$Res> implements $AttendanceCalendarCopyWith<$Res> {
  factory _$AttendanceCalendarCopyWith(_AttendanceCalendar value, $Res Function(_AttendanceCalendar) _then) = __$AttendanceCalendarCopyWithImpl;
@override @useResult
$Res call({
 List<AttendanceDay> days, AttendanceSummary summary,@PlainDateConverter() DateTime today
});


@override $AttendanceSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$AttendanceCalendarCopyWithImpl<$Res>
    implements _$AttendanceCalendarCopyWith<$Res> {
  __$AttendanceCalendarCopyWithImpl(this._self, this._then);

  final _AttendanceCalendar _self;
  final $Res Function(_AttendanceCalendar) _then;

/// Create a copy of AttendanceCalendar
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,Object? summary = null,Object? today = null,}) {
  return _then(_AttendanceCalendar(
days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<AttendanceDay>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as AttendanceSummary,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of AttendanceCalendar
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceSummaryCopyWith<$Res> get summary {
  
  return $AttendanceSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
