// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bundle_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BundleTemplate {

 Map<String, List<int>> get files; TemplateSpec get spec;
/// Create a copy of BundleTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleTemplateCopyWith<BundleTemplate> get copyWith => _$BundleTemplateCopyWithImpl<BundleTemplate>(this as BundleTemplate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleTemplate&&const DeepCollectionEquality().equals(other.files, files)&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(files),spec);

@override
String toString() {
  return 'BundleTemplate(files: $files, spec: $spec)';
}


}

/// @nodoc
abstract mixin class $BundleTemplateCopyWith<$Res>  {
  factory $BundleTemplateCopyWith(BundleTemplate value, $Res Function(BundleTemplate) _then) = _$BundleTemplateCopyWithImpl;
@useResult
$Res call({
 Map<String, List<int>> files, TemplateSpec spec
});


$TemplateSpecCopyWith<$Res> get spec;

}
/// @nodoc
class _$BundleTemplateCopyWithImpl<$Res>
    implements $BundleTemplateCopyWith<$Res> {
  _$BundleTemplateCopyWithImpl(this._self, this._then);

  final BundleTemplate _self;
  final $Res Function(BundleTemplate) _then;

/// Create a copy of BundleTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? files = null,Object? spec = null,}) {
  return _then(_self.copyWith(
files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,spec: null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as TemplateSpec,
  ));
}
/// Create a copy of BundleTemplate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TemplateSpecCopyWith<$Res> get spec {
  
  return $TemplateSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}


/// Adds pattern-matching-related methods to [BundleTemplate].
extension BundleTemplatePatterns on BundleTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleTemplate value)  $default,){
final _that = this;
switch (_that) {
case _BundleTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _BundleTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, List<int>> files,  TemplateSpec spec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleTemplate() when $default != null:
return $default(_that.files,_that.spec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, List<int>> files,  TemplateSpec spec)  $default,) {final _that = this;
switch (_that) {
case _BundleTemplate():
return $default(_that.files,_that.spec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, List<int>> files,  TemplateSpec spec)?  $default,) {final _that = this;
switch (_that) {
case _BundleTemplate() when $default != null:
return $default(_that.files,_that.spec);case _:
  return null;

}
}

}

/// @nodoc


class _BundleTemplate implements BundleTemplate {
  const _BundleTemplate({required final  Map<String, List<int>> files, required this.spec}): _files = files;
  

 final  Map<String, List<int>> _files;
@override Map<String, List<int>> get files {
  if (_files is EqualUnmodifiableMapView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_files);
}

@override final  TemplateSpec spec;

/// Create a copy of BundleTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleTemplateCopyWith<_BundleTemplate> get copyWith => __$BundleTemplateCopyWithImpl<_BundleTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleTemplate&&const DeepCollectionEquality().equals(other._files, _files)&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_files),spec);

@override
String toString() {
  return 'BundleTemplate(files: $files, spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$BundleTemplateCopyWith<$Res> implements $BundleTemplateCopyWith<$Res> {
  factory _$BundleTemplateCopyWith(_BundleTemplate value, $Res Function(_BundleTemplate) _then) = __$BundleTemplateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, List<int>> files, TemplateSpec spec
});


@override $TemplateSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$BundleTemplateCopyWithImpl<$Res>
    implements _$BundleTemplateCopyWith<$Res> {
  __$BundleTemplateCopyWithImpl(this._self, this._then);

  final _BundleTemplate _self;
  final $Res Function(_BundleTemplate) _then;

/// Create a copy of BundleTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? files = null,Object? spec = null,}) {
  return _then(_BundleTemplate(
files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,spec: null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as TemplateSpec,
  ));
}

/// Create a copy of BundleTemplate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TemplateSpecCopyWith<$Res> get spec {
  
  return $TemplateSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

// dart format on
