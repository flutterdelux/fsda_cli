// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TemplateSpec {

 List<String> get dependencies; List<String> get devDependencies; List<String> get postHooks;
/// Create a copy of TemplateSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateSpecCopyWith<TemplateSpec> get copyWith => _$TemplateSpecCopyWithImpl<TemplateSpec>(this as TemplateSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateSpec&&const DeepCollectionEquality().equals(other.dependencies, dependencies)&&const DeepCollectionEquality().equals(other.devDependencies, devDependencies)&&const DeepCollectionEquality().equals(other.postHooks, postHooks));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(dependencies),const DeepCollectionEquality().hash(devDependencies),const DeepCollectionEquality().hash(postHooks));

@override
String toString() {
  return 'TemplateSpec(dependencies: $dependencies, devDependencies: $devDependencies, postHooks: $postHooks)';
}


}

/// @nodoc
abstract mixin class $TemplateSpecCopyWith<$Res>  {
  factory $TemplateSpecCopyWith(TemplateSpec value, $Res Function(TemplateSpec) _then) = _$TemplateSpecCopyWithImpl;
@useResult
$Res call({
 List<String> dependencies, List<String> devDependencies, List<String> postHooks
});




}
/// @nodoc
class _$TemplateSpecCopyWithImpl<$Res>
    implements $TemplateSpecCopyWith<$Res> {
  _$TemplateSpecCopyWithImpl(this._self, this._then);

  final TemplateSpec _self;
  final $Res Function(TemplateSpec) _then;

/// Create a copy of TemplateSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dependencies = null,Object? devDependencies = null,Object? postHooks = null,}) {
  return _then(_self.copyWith(
dependencies: null == dependencies ? _self.dependencies : dependencies // ignore: cast_nullable_to_non_nullable
as List<String>,devDependencies: null == devDependencies ? _self.devDependencies : devDependencies // ignore: cast_nullable_to_non_nullable
as List<String>,postHooks: null == postHooks ? _self.postHooks : postHooks // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateSpec].
extension TemplateSpecPatterns on TemplateSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateSpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateSpec value)  $default,){
final _that = this;
switch (_that) {
case _TemplateSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateSpec value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateSpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> dependencies,  List<String> devDependencies,  List<String> postHooks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateSpec() when $default != null:
return $default(_that.dependencies,_that.devDependencies,_that.postHooks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> dependencies,  List<String> devDependencies,  List<String> postHooks)  $default,) {final _that = this;
switch (_that) {
case _TemplateSpec():
return $default(_that.dependencies,_that.devDependencies,_that.postHooks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> dependencies,  List<String> devDependencies,  List<String> postHooks)?  $default,) {final _that = this;
switch (_that) {
case _TemplateSpec() when $default != null:
return $default(_that.dependencies,_that.devDependencies,_that.postHooks);case _:
  return null;

}
}

}

/// @nodoc


class _TemplateSpec extends TemplateSpec {
  const _TemplateSpec({required final  List<String> dependencies, required final  List<String> devDependencies, required final  List<String> postHooks}): _dependencies = dependencies,_devDependencies = devDependencies,_postHooks = postHooks,super._();
  

 final  List<String> _dependencies;
@override List<String> get dependencies {
  if (_dependencies is EqualUnmodifiableListView) return _dependencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dependencies);
}

 final  List<String> _devDependencies;
@override List<String> get devDependencies {
  if (_devDependencies is EqualUnmodifiableListView) return _devDependencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_devDependencies);
}

 final  List<String> _postHooks;
@override List<String> get postHooks {
  if (_postHooks is EqualUnmodifiableListView) return _postHooks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_postHooks);
}


/// Create a copy of TemplateSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateSpecCopyWith<_TemplateSpec> get copyWith => __$TemplateSpecCopyWithImpl<_TemplateSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateSpec&&const DeepCollectionEquality().equals(other._dependencies, _dependencies)&&const DeepCollectionEquality().equals(other._devDependencies, _devDependencies)&&const DeepCollectionEquality().equals(other._postHooks, _postHooks));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dependencies),const DeepCollectionEquality().hash(_devDependencies),const DeepCollectionEquality().hash(_postHooks));

@override
String toString() {
  return 'TemplateSpec(dependencies: $dependencies, devDependencies: $devDependencies, postHooks: $postHooks)';
}


}

/// @nodoc
abstract mixin class _$TemplateSpecCopyWith<$Res> implements $TemplateSpecCopyWith<$Res> {
  factory _$TemplateSpecCopyWith(_TemplateSpec value, $Res Function(_TemplateSpec) _then) = __$TemplateSpecCopyWithImpl;
@override @useResult
$Res call({
 List<String> dependencies, List<String> devDependencies, List<String> postHooks
});




}
/// @nodoc
class __$TemplateSpecCopyWithImpl<$Res>
    implements _$TemplateSpecCopyWith<$Res> {
  __$TemplateSpecCopyWithImpl(this._self, this._then);

  final _TemplateSpec _self;
  final $Res Function(_TemplateSpec) _then;

/// Create a copy of TemplateSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dependencies = null,Object? devDependencies = null,Object? postHooks = null,}) {
  return _then(_TemplateSpec(
dependencies: null == dependencies ? _self._dependencies : dependencies // ignore: cast_nullable_to_non_nullable
as List<String>,devDependencies: null == devDependencies ? _self._devDependencies : devDependencies // ignore: cast_nullable_to_non_nullable
as List<String>,postHooks: null == postHooks ? _self._postHooks : postHooks // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
