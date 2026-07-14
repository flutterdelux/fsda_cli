// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'di_param.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiParam {

 String get name; bool get isNamed; String? get typeName;
/// Create a copy of DiParam
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiParamCopyWith<DiParam> get copyWith => _$DiParamCopyWithImpl<DiParam>(this as DiParam, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiParam&&(identical(other.name, name) || other.name == name)&&(identical(other.isNamed, isNamed) || other.isNamed == isNamed)&&(identical(other.typeName, typeName) || other.typeName == typeName));
}


@override
int get hashCode => Object.hash(runtimeType,name,isNamed,typeName);

@override
String toString() {
  return 'DiParam(name: $name, isNamed: $isNamed, typeName: $typeName)';
}


}

/// @nodoc
abstract mixin class $DiParamCopyWith<$Res>  {
  factory $DiParamCopyWith(DiParam value, $Res Function(DiParam) _then) = _$DiParamCopyWithImpl;
@useResult
$Res call({
 String name, bool isNamed, String? typeName
});




}
/// @nodoc
class _$DiParamCopyWithImpl<$Res>
    implements $DiParamCopyWith<$Res> {
  _$DiParamCopyWithImpl(this._self, this._then);

  final DiParam _self;
  final $Res Function(DiParam) _then;

/// Create a copy of DiParam
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? isNamed = null,Object? typeName = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isNamed: null == isNamed ? _self.isNamed : isNamed // ignore: cast_nullable_to_non_nullable
as bool,typeName: freezed == typeName ? _self.typeName : typeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiParam].
extension DiParamPatterns on DiParam {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiParam value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiParam() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiParam value)  $default,){
final _that = this;
switch (_that) {
case _DiParam():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiParam value)?  $default,){
final _that = this;
switch (_that) {
case _DiParam() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  bool isNamed,  String? typeName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiParam() when $default != null:
return $default(_that.name,_that.isNamed,_that.typeName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  bool isNamed,  String? typeName)  $default,) {final _that = this;
switch (_that) {
case _DiParam():
return $default(_that.name,_that.isNamed,_that.typeName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  bool isNamed,  String? typeName)?  $default,) {final _that = this;
switch (_that) {
case _DiParam() when $default != null:
return $default(_that.name,_that.isNamed,_that.typeName);case _:
  return null;

}
}

}

/// @nodoc


class _DiParam implements DiParam {
  const _DiParam({required this.name, required this.isNamed, this.typeName});
  

@override final  String name;
@override final  bool isNamed;
@override final  String? typeName;

/// Create a copy of DiParam
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiParamCopyWith<_DiParam> get copyWith => __$DiParamCopyWithImpl<_DiParam>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiParam&&(identical(other.name, name) || other.name == name)&&(identical(other.isNamed, isNamed) || other.isNamed == isNamed)&&(identical(other.typeName, typeName) || other.typeName == typeName));
}


@override
int get hashCode => Object.hash(runtimeType,name,isNamed,typeName);

@override
String toString() {
  return 'DiParam(name: $name, isNamed: $isNamed, typeName: $typeName)';
}


}

/// @nodoc
abstract mixin class _$DiParamCopyWith<$Res> implements $DiParamCopyWith<$Res> {
  factory _$DiParamCopyWith(_DiParam value, $Res Function(_DiParam) _then) = __$DiParamCopyWithImpl;
@override @useResult
$Res call({
 String name, bool isNamed, String? typeName
});




}
/// @nodoc
class __$DiParamCopyWithImpl<$Res>
    implements _$DiParamCopyWith<$Res> {
  __$DiParamCopyWithImpl(this._self, this._then);

  final _DiParam _self;
  final $Res Function(_DiParam) _then;

/// Create a copy of DiParam
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? isNamed = null,Object? typeName = freezed,}) {
  return _then(_DiParam(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isNamed: null == isNamed ? _self.isNamed : isNamed // ignore: cast_nullable_to_non_nullable
as bool,typeName: freezed == typeName ? _self.typeName : typeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
