// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'di_class_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiClassInfo {

 String get className; String? get interfaceName; List<DiParam> get parameters; DiClassType? get type; String? get importPath;
/// Create a copy of DiClassInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiClassInfoCopyWith<DiClassInfo> get copyWith => _$DiClassInfoCopyWithImpl<DiClassInfo>(this as DiClassInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiClassInfo&&(identical(other.className, className) || other.className == className)&&(identical(other.interfaceName, interfaceName) || other.interfaceName == interfaceName)&&const DeepCollectionEquality().equals(other.parameters, parameters)&&(identical(other.type, type) || other.type == type)&&(identical(other.importPath, importPath) || other.importPath == importPath));
}


@override
int get hashCode => Object.hash(runtimeType,className,interfaceName,const DeepCollectionEquality().hash(parameters),type,importPath);

@override
String toString() {
  return 'DiClassInfo(className: $className, interfaceName: $interfaceName, parameters: $parameters, type: $type, importPath: $importPath)';
}


}

/// @nodoc
abstract mixin class $DiClassInfoCopyWith<$Res>  {
  factory $DiClassInfoCopyWith(DiClassInfo value, $Res Function(DiClassInfo) _then) = _$DiClassInfoCopyWithImpl;
@useResult
$Res call({
 String className, String? interfaceName, List<DiParam> parameters, DiClassType? type, String? importPath
});




}
/// @nodoc
class _$DiClassInfoCopyWithImpl<$Res>
    implements $DiClassInfoCopyWith<$Res> {
  _$DiClassInfoCopyWithImpl(this._self, this._then);

  final DiClassInfo _self;
  final $Res Function(DiClassInfo) _then;

/// Create a copy of DiClassInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? className = null,Object? interfaceName = freezed,Object? parameters = null,Object? type = freezed,Object? importPath = freezed,}) {
  return _then(_self.copyWith(
className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,interfaceName: freezed == interfaceName ? _self.interfaceName : interfaceName // ignore: cast_nullable_to_non_nullable
as String?,parameters: null == parameters ? _self.parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<DiParam>,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiClassType?,importPath: freezed == importPath ? _self.importPath : importPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiClassInfo].
extension DiClassInfoPatterns on DiClassInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiClassInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiClassInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiClassInfo value)  $default,){
final _that = this;
switch (_that) {
case _DiClassInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiClassInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DiClassInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String className,  String? interfaceName,  List<DiParam> parameters,  DiClassType? type,  String? importPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiClassInfo() when $default != null:
return $default(_that.className,_that.interfaceName,_that.parameters,_that.type,_that.importPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String className,  String? interfaceName,  List<DiParam> parameters,  DiClassType? type,  String? importPath)  $default,) {final _that = this;
switch (_that) {
case _DiClassInfo():
return $default(_that.className,_that.interfaceName,_that.parameters,_that.type,_that.importPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String className,  String? interfaceName,  List<DiParam> parameters,  DiClassType? type,  String? importPath)?  $default,) {final _that = this;
switch (_that) {
case _DiClassInfo() when $default != null:
return $default(_that.className,_that.interfaceName,_that.parameters,_that.type,_that.importPath);case _:
  return null;

}
}

}

/// @nodoc


class _DiClassInfo implements DiClassInfo {
  const _DiClassInfo({required this.className, this.interfaceName, required final  List<DiParam> parameters, required this.type, this.importPath}): _parameters = parameters;
  

@override final  String className;
@override final  String? interfaceName;
 final  List<DiParam> _parameters;
@override List<DiParam> get parameters {
  if (_parameters is EqualUnmodifiableListView) return _parameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parameters);
}

@override final  DiClassType? type;
@override final  String? importPath;

/// Create a copy of DiClassInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiClassInfoCopyWith<_DiClassInfo> get copyWith => __$DiClassInfoCopyWithImpl<_DiClassInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiClassInfo&&(identical(other.className, className) || other.className == className)&&(identical(other.interfaceName, interfaceName) || other.interfaceName == interfaceName)&&const DeepCollectionEquality().equals(other._parameters, _parameters)&&(identical(other.type, type) || other.type == type)&&(identical(other.importPath, importPath) || other.importPath == importPath));
}


@override
int get hashCode => Object.hash(runtimeType,className,interfaceName,const DeepCollectionEquality().hash(_parameters),type,importPath);

@override
String toString() {
  return 'DiClassInfo(className: $className, interfaceName: $interfaceName, parameters: $parameters, type: $type, importPath: $importPath)';
}


}

/// @nodoc
abstract mixin class _$DiClassInfoCopyWith<$Res> implements $DiClassInfoCopyWith<$Res> {
  factory _$DiClassInfoCopyWith(_DiClassInfo value, $Res Function(_DiClassInfo) _then) = __$DiClassInfoCopyWithImpl;
@override @useResult
$Res call({
 String className, String? interfaceName, List<DiParam> parameters, DiClassType? type, String? importPath
});




}
/// @nodoc
class __$DiClassInfoCopyWithImpl<$Res>
    implements _$DiClassInfoCopyWith<$Res> {
  __$DiClassInfoCopyWithImpl(this._self, this._then);

  final _DiClassInfo _self;
  final $Res Function(_DiClassInfo) _then;

/// Create a copy of DiClassInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? className = null,Object? interfaceName = freezed,Object? parameters = null,Object? type = freezed,Object? importPath = freezed,}) {
  return _then(_DiClassInfo(
className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,interfaceName: freezed == interfaceName ? _self.interfaceName : interfaceName // ignore: cast_nullable_to_non_nullable
as String?,parameters: null == parameters ? _self._parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<DiParam>,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiClassType?,importPath: freezed == importPath ? _self.importPath : importPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
