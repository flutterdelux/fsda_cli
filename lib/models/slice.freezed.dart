// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Slice {

/// r, rp, m, mp, etc
 String get mode;/// slice name
 String get name; String get feature; String get module;/// use camelCase
 String get method;/// modelling use snake_case
 String? get param; String? get request; String? get entity; String? get dto;/// for retrieval
 bool get returnList;
/// Create a copy of Slice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SliceCopyWith<Slice> get copyWith => _$SliceCopyWithImpl<Slice>(this as Slice, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Slice&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.name, name) || other.name == name)&&(identical(other.feature, feature) || other.feature == feature)&&(identical(other.module, module) || other.module == module)&&(identical(other.method, method) || other.method == method)&&(identical(other.param, param) || other.param == param)&&(identical(other.request, request) || other.request == request)&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.dto, dto) || other.dto == dto)&&(identical(other.returnList, returnList) || other.returnList == returnList));
}


@override
int get hashCode => Object.hash(runtimeType,mode,name,feature,module,method,param,request,entity,dto,returnList);

@override
String toString() {
  return 'Slice(mode: $mode, name: $name, feature: $feature, module: $module, method: $method, param: $param, request: $request, entity: $entity, dto: $dto, returnList: $returnList)';
}


}

/// @nodoc
abstract mixin class $SliceCopyWith<$Res>  {
  factory $SliceCopyWith(Slice value, $Res Function(Slice) _then) = _$SliceCopyWithImpl;
@useResult
$Res call({
 String mode, String name, String feature, String module, String method, String? param, String? request, String? entity, String? dto, bool returnList
});




}
/// @nodoc
class _$SliceCopyWithImpl<$Res>
    implements $SliceCopyWith<$Res> {
  _$SliceCopyWithImpl(this._self, this._then);

  final Slice _self;
  final $Res Function(Slice) _then;

/// Create a copy of Slice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? name = null,Object? feature = null,Object? module = null,Object? method = null,Object? param = freezed,Object? request = freezed,Object? entity = freezed,Object? dto = freezed,Object? returnList = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,feature: null == feature ? _self.feature : feature // ignore: cast_nullable_to_non_nullable
as String,module: null == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,param: freezed == param ? _self.param : param // ignore: cast_nullable_to_non_nullable
as String?,request: freezed == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as String?,entity: freezed == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as String?,dto: freezed == dto ? _self.dto : dto // ignore: cast_nullable_to_non_nullable
as String?,returnList: null == returnList ? _self.returnList : returnList // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Slice].
extension SlicePatterns on Slice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Slice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Slice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Slice value)  $default,){
final _that = this;
switch (_that) {
case _Slice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Slice value)?  $default,){
final _that = this;
switch (_that) {
case _Slice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mode,  String name,  String feature,  String module,  String method,  String? param,  String? request,  String? entity,  String? dto,  bool returnList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Slice() when $default != null:
return $default(_that.mode,_that.name,_that.feature,_that.module,_that.method,_that.param,_that.request,_that.entity,_that.dto,_that.returnList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mode,  String name,  String feature,  String module,  String method,  String? param,  String? request,  String? entity,  String? dto,  bool returnList)  $default,) {final _that = this;
switch (_that) {
case _Slice():
return $default(_that.mode,_that.name,_that.feature,_that.module,_that.method,_that.param,_that.request,_that.entity,_that.dto,_that.returnList);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mode,  String name,  String feature,  String module,  String method,  String? param,  String? request,  String? entity,  String? dto,  bool returnList)?  $default,) {final _that = this;
switch (_that) {
case _Slice() when $default != null:
return $default(_that.mode,_that.name,_that.feature,_that.module,_that.method,_that.param,_that.request,_that.entity,_that.dto,_that.returnList);case _:
  return null;

}
}

}

/// @nodoc


class _Slice implements Slice {
  const _Slice({required this.mode, required this.name, required this.feature, required this.module, required this.method, this.param, this.request, this.entity, this.dto, this.returnList = false});
  

/// r, rp, m, mp, etc
@override final  String mode;
/// slice name
@override final  String name;
@override final  String feature;
@override final  String module;
/// use camelCase
@override final  String method;
/// modelling use snake_case
@override final  String? param;
@override final  String? request;
@override final  String? entity;
@override final  String? dto;
/// for retrieval
@override@JsonKey() final  bool returnList;

/// Create a copy of Slice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SliceCopyWith<_Slice> get copyWith => __$SliceCopyWithImpl<_Slice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Slice&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.name, name) || other.name == name)&&(identical(other.feature, feature) || other.feature == feature)&&(identical(other.module, module) || other.module == module)&&(identical(other.method, method) || other.method == method)&&(identical(other.param, param) || other.param == param)&&(identical(other.request, request) || other.request == request)&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.dto, dto) || other.dto == dto)&&(identical(other.returnList, returnList) || other.returnList == returnList));
}


@override
int get hashCode => Object.hash(runtimeType,mode,name,feature,module,method,param,request,entity,dto,returnList);

@override
String toString() {
  return 'Slice(mode: $mode, name: $name, feature: $feature, module: $module, method: $method, param: $param, request: $request, entity: $entity, dto: $dto, returnList: $returnList)';
}


}

/// @nodoc
abstract mixin class _$SliceCopyWith<$Res> implements $SliceCopyWith<$Res> {
  factory _$SliceCopyWith(_Slice value, $Res Function(_Slice) _then) = __$SliceCopyWithImpl;
@override @useResult
$Res call({
 String mode, String name, String feature, String module, String method, String? param, String? request, String? entity, String? dto, bool returnList
});




}
/// @nodoc
class __$SliceCopyWithImpl<$Res>
    implements _$SliceCopyWith<$Res> {
  __$SliceCopyWithImpl(this._self, this._then);

  final _Slice _self;
  final $Res Function(_Slice) _then;

/// Create a copy of Slice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? name = null,Object? feature = null,Object? module = null,Object? method = null,Object? param = freezed,Object? request = freezed,Object? entity = freezed,Object? dto = freezed,Object? returnList = null,}) {
  return _then(_Slice(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,feature: null == feature ? _self.feature : feature // ignore: cast_nullable_to_non_nullable
as String,module: null == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,param: freezed == param ? _self.param : param // ignore: cast_nullable_to_non_nullable
as String?,request: freezed == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as String?,entity: freezed == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as String?,dto: freezed == dto ? _self.dto : dto // ignore: cast_nullable_to_non_nullable
as String?,returnList: null == returnList ? _self.returnList : returnList // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
