// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Membership {

 String get id; String get planId;// Snapshot of the plan name as sold.
 String get planName;// Raw `plan_type` wire value. Kept as a string: this app only displays the
// plan name, and a new plan type must not stop the history loading.
 String get planType;// `date` columns: calendar days, never shifted by an offset.
@PlainDateConverter() DateTime get startDate;@NullablePlainDateConverter() DateTime? get endDate; int? get sessionsTotal; int? get sessionsRemaining;// Integer paisa.
 int get pricePaisa; int get discountPaisa; MembershipStatus get status; DateTime get createdAt;
/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipCopyWith<Membership> get copyWith => _$MembershipCopyWithImpl<Membership>(this as Membership, _$identity);

  /// Serializes this Membership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Membership&&(identical(other.id, id) || other.id == id)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.sessionsTotal, sessionsTotal) || other.sessionsTotal == sessionsTotal)&&(identical(other.sessionsRemaining, sessionsRemaining) || other.sessionsRemaining == sessionsRemaining)&&(identical(other.pricePaisa, pricePaisa) || other.pricePaisa == pricePaisa)&&(identical(other.discountPaisa, discountPaisa) || other.discountPaisa == discountPaisa)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,planId,planName,planType,startDate,endDate,sessionsTotal,sessionsRemaining,pricePaisa,discountPaisa,status,createdAt);

@override
String toString() {
  return 'Membership(id: $id, planId: $planId, planName: $planName, planType: $planType, startDate: $startDate, endDate: $endDate, sessionsTotal: $sessionsTotal, sessionsRemaining: $sessionsRemaining, pricePaisa: $pricePaisa, discountPaisa: $discountPaisa, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MembershipCopyWith<$Res>  {
  factory $MembershipCopyWith(Membership value, $Res Function(Membership) _then) = _$MembershipCopyWithImpl;
@useResult
$Res call({
 String id, String planId, String planName, String planType,@PlainDateConverter() DateTime startDate,@NullablePlainDateConverter() DateTime? endDate, int? sessionsTotal, int? sessionsRemaining, int pricePaisa, int discountPaisa, MembershipStatus status, DateTime createdAt
});




}
/// @nodoc
class _$MembershipCopyWithImpl<$Res>
    implements $MembershipCopyWith<$Res> {
  _$MembershipCopyWithImpl(this._self, this._then);

  final Membership _self;
  final $Res Function(Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? planId = null,Object? planName = null,Object? planType = null,Object? startDate = null,Object? endDate = freezed,Object? sessionsTotal = freezed,Object? sessionsRemaining = freezed,Object? pricePaisa = null,Object? discountPaisa = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sessionsTotal: freezed == sessionsTotal ? _self.sessionsTotal : sessionsTotal // ignore: cast_nullable_to_non_nullable
as int?,sessionsRemaining: freezed == sessionsRemaining ? _self.sessionsRemaining : sessionsRemaining // ignore: cast_nullable_to_non_nullable
as int?,pricePaisa: null == pricePaisa ? _self.pricePaisa : pricePaisa // ignore: cast_nullable_to_non_nullable
as int,discountPaisa: null == discountPaisa ? _self.discountPaisa : discountPaisa // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Membership].
extension MembershipPatterns on Membership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Membership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Membership value)  $default,){
final _that = this;
switch (_that) {
case _Membership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Membership value)?  $default,){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String planId,  String planName,  String planType, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int? sessionsTotal,  int? sessionsRemaining,  int pricePaisa,  int discountPaisa,  MembershipStatus status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.id,_that.planId,_that.planName,_that.planType,_that.startDate,_that.endDate,_that.sessionsTotal,_that.sessionsRemaining,_that.pricePaisa,_that.discountPaisa,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String planId,  String planName,  String planType, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int? sessionsTotal,  int? sessionsRemaining,  int pricePaisa,  int discountPaisa,  MembershipStatus status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Membership():
return $default(_that.id,_that.planId,_that.planName,_that.planType,_that.startDate,_that.endDate,_that.sessionsTotal,_that.sessionsRemaining,_that.pricePaisa,_that.discountPaisa,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String planId,  String planName,  String planType, @PlainDateConverter()  DateTime startDate, @NullablePlainDateConverter()  DateTime? endDate,  int? sessionsTotal,  int? sessionsRemaining,  int pricePaisa,  int discountPaisa,  MembershipStatus status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.id,_that.planId,_that.planName,_that.planType,_that.startDate,_that.endDate,_that.sessionsTotal,_that.sessionsRemaining,_that.pricePaisa,_that.discountPaisa,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Membership implements Membership {
  const _Membership({required this.id, required this.planId, required this.planName, required this.planType, @PlainDateConverter() required this.startDate, @NullablePlainDateConverter() this.endDate, this.sessionsTotal, this.sessionsRemaining, required this.pricePaisa, required this.discountPaisa, required this.status, required this.createdAt});
  factory _Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);

@override final  String id;
@override final  String planId;
// Snapshot of the plan name as sold.
@override final  String planName;
// Raw `plan_type` wire value. Kept as a string: this app only displays the
// plan name, and a new plan type must not stop the history loading.
@override final  String planType;
// `date` columns: calendar days, never shifted by an offset.
@override@PlainDateConverter() final  DateTime startDate;
@override@NullablePlainDateConverter() final  DateTime? endDate;
@override final  int? sessionsTotal;
@override final  int? sessionsRemaining;
// Integer paisa.
@override final  int pricePaisa;
@override final  int discountPaisa;
@override final  MembershipStatus status;
@override final  DateTime createdAt;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipCopyWith<_Membership> get copyWith => __$MembershipCopyWithImpl<_Membership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Membership&&(identical(other.id, id) || other.id == id)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.sessionsTotal, sessionsTotal) || other.sessionsTotal == sessionsTotal)&&(identical(other.sessionsRemaining, sessionsRemaining) || other.sessionsRemaining == sessionsRemaining)&&(identical(other.pricePaisa, pricePaisa) || other.pricePaisa == pricePaisa)&&(identical(other.discountPaisa, discountPaisa) || other.discountPaisa == discountPaisa)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,planId,planName,planType,startDate,endDate,sessionsTotal,sessionsRemaining,pricePaisa,discountPaisa,status,createdAt);

@override
String toString() {
  return 'Membership(id: $id, planId: $planId, planName: $planName, planType: $planType, startDate: $startDate, endDate: $endDate, sessionsTotal: $sessionsTotal, sessionsRemaining: $sessionsRemaining, pricePaisa: $pricePaisa, discountPaisa: $discountPaisa, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MembershipCopyWith<$Res> implements $MembershipCopyWith<$Res> {
  factory _$MembershipCopyWith(_Membership value, $Res Function(_Membership) _then) = __$MembershipCopyWithImpl;
@override @useResult
$Res call({
 String id, String planId, String planName, String planType,@PlainDateConverter() DateTime startDate,@NullablePlainDateConverter() DateTime? endDate, int? sessionsTotal, int? sessionsRemaining, int pricePaisa, int discountPaisa, MembershipStatus status, DateTime createdAt
});




}
/// @nodoc
class __$MembershipCopyWithImpl<$Res>
    implements _$MembershipCopyWith<$Res> {
  __$MembershipCopyWithImpl(this._self, this._then);

  final _Membership _self;
  final $Res Function(_Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? planId = null,Object? planName = null,Object? planType = null,Object? startDate = null,Object? endDate = freezed,Object? sessionsTotal = freezed,Object? sessionsRemaining = freezed,Object? pricePaisa = null,Object? discountPaisa = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_Membership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sessionsTotal: freezed == sessionsTotal ? _self.sessionsTotal : sessionsTotal // ignore: cast_nullable_to_non_nullable
as int?,sessionsRemaining: freezed == sessionsRemaining ? _self.sessionsRemaining : sessionsRemaining // ignore: cast_nullable_to_non_nullable
as int?,pricePaisa: null == pricePaisa ? _self.pricePaisa : pricePaisa // ignore: cast_nullable_to_non_nullable
as int,discountPaisa: null == discountPaisa ? _self.discountPaisa : discountPaisa // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
