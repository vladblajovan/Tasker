// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurrence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Recurrence {

 RecurrenceType get type; int get interval; List<int>? get weekdays; DateTime? get endDate;
/// Create a copy of Recurrence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurrenceCopyWith<Recurrence> get copyWith => _$RecurrenceCopyWithImpl<Recurrence>(this as Recurrence, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recurrence&&(identical(other.type, type) || other.type == type)&&(identical(other.interval, interval) || other.interval == interval)&&const DeepCollectionEquality().equals(other.weekdays, weekdays)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,type,interval,const DeepCollectionEquality().hash(weekdays),endDate);

@override
String toString() {
  return 'Recurrence(type: $type, interval: $interval, weekdays: $weekdays, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $RecurrenceCopyWith<$Res>  {
  factory $RecurrenceCopyWith(Recurrence value, $Res Function(Recurrence) _then) = _$RecurrenceCopyWithImpl;
@useResult
$Res call({
 RecurrenceType type, int interval, List<int>? weekdays, DateTime? endDate
});




}
/// @nodoc
class _$RecurrenceCopyWithImpl<$Res>
    implements $RecurrenceCopyWith<$Res> {
  _$RecurrenceCopyWithImpl(this._self, this._then);

  final Recurrence _self;
  final $Res Function(Recurrence) _then;

/// Create a copy of Recurrence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? interval = null,Object? weekdays = freezed,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecurrenceType,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,weekdays: freezed == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as List<int>?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Recurrence].
extension RecurrencePatterns on Recurrence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recurrence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recurrence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recurrence value)  $default,){
final _that = this;
switch (_that) {
case _Recurrence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recurrence value)?  $default,){
final _that = this;
switch (_that) {
case _Recurrence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecurrenceType type,  int interval,  List<int>? weekdays,  DateTime? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recurrence() when $default != null:
return $default(_that.type,_that.interval,_that.weekdays,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecurrenceType type,  int interval,  List<int>? weekdays,  DateTime? endDate)  $default,) {final _that = this;
switch (_that) {
case _Recurrence():
return $default(_that.type,_that.interval,_that.weekdays,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecurrenceType type,  int interval,  List<int>? weekdays,  DateTime? endDate)?  $default,) {final _that = this;
switch (_that) {
case _Recurrence() when $default != null:
return $default(_that.type,_that.interval,_that.weekdays,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc


class _Recurrence implements Recurrence {
  const _Recurrence({required this.type, required this.interval, final  List<int>? weekdays, this.endDate}): _weekdays = weekdays;
  

@override final  RecurrenceType type;
@override final  int interval;
 final  List<int>? _weekdays;
@override List<int>? get weekdays {
  final value = _weekdays;
  if (value == null) return null;
  if (_weekdays is EqualUnmodifiableListView) return _weekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  DateTime? endDate;

/// Create a copy of Recurrence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurrenceCopyWith<_Recurrence> get copyWith => __$RecurrenceCopyWithImpl<_Recurrence>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recurrence&&(identical(other.type, type) || other.type == type)&&(identical(other.interval, interval) || other.interval == interval)&&const DeepCollectionEquality().equals(other._weekdays, _weekdays)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,type,interval,const DeepCollectionEquality().hash(_weekdays),endDate);

@override
String toString() {
  return 'Recurrence(type: $type, interval: $interval, weekdays: $weekdays, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$RecurrenceCopyWith<$Res> implements $RecurrenceCopyWith<$Res> {
  factory _$RecurrenceCopyWith(_Recurrence value, $Res Function(_Recurrence) _then) = __$RecurrenceCopyWithImpl;
@override @useResult
$Res call({
 RecurrenceType type, int interval, List<int>? weekdays, DateTime? endDate
});




}
/// @nodoc
class __$RecurrenceCopyWithImpl<$Res>
    implements _$RecurrenceCopyWith<$Res> {
  __$RecurrenceCopyWithImpl(this._self, this._then);

  final _Recurrence _self;
  final $Res Function(_Recurrence) _then;

/// Create a copy of Recurrence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? interval = null,Object? weekdays = freezed,Object? endDate = freezed,}) {
  return _then(_Recurrence(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecurrenceType,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,weekdays: freezed == weekdays ? _self._weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as List<int>?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
