// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'infra_template_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InfraTemplateSpec {

 String get packageName; Set<String> get coreDiImports; String? get coreDiCode; Set<String> get externalDiImports; String? get externalDiCode; Set<String> get externalCodeImports; String? get externalCode; Set<String> get appDependencies;
/// Create a copy of InfraTemplateSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InfraTemplateSpecCopyWith<InfraTemplateSpec> get copyWith => _$InfraTemplateSpecCopyWithImpl<InfraTemplateSpec>(this as InfraTemplateSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InfraTemplateSpec&&(identical(other.packageName, packageName) || other.packageName == packageName)&&const DeepCollectionEquality().equals(other.coreDiImports, coreDiImports)&&(identical(other.coreDiCode, coreDiCode) || other.coreDiCode == coreDiCode)&&const DeepCollectionEquality().equals(other.externalDiImports, externalDiImports)&&(identical(other.externalDiCode, externalDiCode) || other.externalDiCode == externalDiCode)&&const DeepCollectionEquality().equals(other.externalCodeImports, externalCodeImports)&&(identical(other.externalCode, externalCode) || other.externalCode == externalCode)&&const DeepCollectionEquality().equals(other.appDependencies, appDependencies));
}


@override
int get hashCode => Object.hash(runtimeType,packageName,const DeepCollectionEquality().hash(coreDiImports),coreDiCode,const DeepCollectionEquality().hash(externalDiImports),externalDiCode,const DeepCollectionEquality().hash(externalCodeImports),externalCode,const DeepCollectionEquality().hash(appDependencies));

@override
String toString() {
  return 'InfraTemplateSpec(packageName: $packageName, coreDiImports: $coreDiImports, coreDiCode: $coreDiCode, externalDiImports: $externalDiImports, externalDiCode: $externalDiCode, externalCodeImports: $externalCodeImports, externalCode: $externalCode, appDependencies: $appDependencies)';
}


}

/// @nodoc
abstract mixin class $InfraTemplateSpecCopyWith<$Res>  {
  factory $InfraTemplateSpecCopyWith(InfraTemplateSpec value, $Res Function(InfraTemplateSpec) _then) = _$InfraTemplateSpecCopyWithImpl;
@useResult
$Res call({
 String packageName, Set<String> coreDiImports, String? coreDiCode, Set<String> externalDiImports, String? externalDiCode, Set<String> externalCodeImports, String? externalCode, Set<String> appDependencies
});




}
/// @nodoc
class _$InfraTemplateSpecCopyWithImpl<$Res>
    implements $InfraTemplateSpecCopyWith<$Res> {
  _$InfraTemplateSpecCopyWithImpl(this._self, this._then);

  final InfraTemplateSpec _self;
  final $Res Function(InfraTemplateSpec) _then;

/// Create a copy of InfraTemplateSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageName = null,Object? coreDiImports = null,Object? coreDiCode = freezed,Object? externalDiImports = null,Object? externalDiCode = freezed,Object? externalCodeImports = null,Object? externalCode = freezed,Object? appDependencies = null,}) {
  return _then(_self.copyWith(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,coreDiImports: null == coreDiImports ? _self.coreDiImports : coreDiImports // ignore: cast_nullable_to_non_nullable
as Set<String>,coreDiCode: freezed == coreDiCode ? _self.coreDiCode : coreDiCode // ignore: cast_nullable_to_non_nullable
as String?,externalDiImports: null == externalDiImports ? _self.externalDiImports : externalDiImports // ignore: cast_nullable_to_non_nullable
as Set<String>,externalDiCode: freezed == externalDiCode ? _self.externalDiCode : externalDiCode // ignore: cast_nullable_to_non_nullable
as String?,externalCodeImports: null == externalCodeImports ? _self.externalCodeImports : externalCodeImports // ignore: cast_nullable_to_non_nullable
as Set<String>,externalCode: freezed == externalCode ? _self.externalCode : externalCode // ignore: cast_nullable_to_non_nullable
as String?,appDependencies: null == appDependencies ? _self.appDependencies : appDependencies // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [InfraTemplateSpec].
extension InfraTemplateSpecPatterns on InfraTemplateSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InfraTemplateSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InfraTemplateSpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InfraTemplateSpec value)  $default,){
final _that = this;
switch (_that) {
case _InfraTemplateSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InfraTemplateSpec value)?  $default,){
final _that = this;
switch (_that) {
case _InfraTemplateSpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packageName,  Set<String> coreDiImports,  String? coreDiCode,  Set<String> externalDiImports,  String? externalDiCode,  Set<String> externalCodeImports,  String? externalCode,  Set<String> appDependencies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InfraTemplateSpec() when $default != null:
return $default(_that.packageName,_that.coreDiImports,_that.coreDiCode,_that.externalDiImports,_that.externalDiCode,_that.externalCodeImports,_that.externalCode,_that.appDependencies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packageName,  Set<String> coreDiImports,  String? coreDiCode,  Set<String> externalDiImports,  String? externalDiCode,  Set<String> externalCodeImports,  String? externalCode,  Set<String> appDependencies)  $default,) {final _that = this;
switch (_that) {
case _InfraTemplateSpec():
return $default(_that.packageName,_that.coreDiImports,_that.coreDiCode,_that.externalDiImports,_that.externalDiCode,_that.externalCodeImports,_that.externalCode,_that.appDependencies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packageName,  Set<String> coreDiImports,  String? coreDiCode,  Set<String> externalDiImports,  String? externalDiCode,  Set<String> externalCodeImports,  String? externalCode,  Set<String> appDependencies)?  $default,) {final _that = this;
switch (_that) {
case _InfraTemplateSpec() when $default != null:
return $default(_that.packageName,_that.coreDiImports,_that.coreDiCode,_that.externalDiImports,_that.externalDiCode,_that.externalCodeImports,_that.externalCode,_that.appDependencies);case _:
  return null;

}
}

}

/// @nodoc


class _InfraTemplateSpec implements InfraTemplateSpec {
  const _InfraTemplateSpec({required this.packageName, required final  Set<String> coreDiImports, this.coreDiCode, required final  Set<String> externalDiImports, this.externalDiCode, required final  Set<String> externalCodeImports, this.externalCode, required final  Set<String> appDependencies}): _coreDiImports = coreDiImports,_externalDiImports = externalDiImports,_externalCodeImports = externalCodeImports,_appDependencies = appDependencies;
  

@override final  String packageName;
 final  Set<String> _coreDiImports;
@override Set<String> get coreDiImports {
  if (_coreDiImports is EqualUnmodifiableSetView) return _coreDiImports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_coreDiImports);
}

@override final  String? coreDiCode;
 final  Set<String> _externalDiImports;
@override Set<String> get externalDiImports {
  if (_externalDiImports is EqualUnmodifiableSetView) return _externalDiImports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_externalDiImports);
}

@override final  String? externalDiCode;
 final  Set<String> _externalCodeImports;
@override Set<String> get externalCodeImports {
  if (_externalCodeImports is EqualUnmodifiableSetView) return _externalCodeImports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_externalCodeImports);
}

@override final  String? externalCode;
 final  Set<String> _appDependencies;
@override Set<String> get appDependencies {
  if (_appDependencies is EqualUnmodifiableSetView) return _appDependencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_appDependencies);
}


/// Create a copy of InfraTemplateSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InfraTemplateSpecCopyWith<_InfraTemplateSpec> get copyWith => __$InfraTemplateSpecCopyWithImpl<_InfraTemplateSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InfraTemplateSpec&&(identical(other.packageName, packageName) || other.packageName == packageName)&&const DeepCollectionEquality().equals(other._coreDiImports, _coreDiImports)&&(identical(other.coreDiCode, coreDiCode) || other.coreDiCode == coreDiCode)&&const DeepCollectionEquality().equals(other._externalDiImports, _externalDiImports)&&(identical(other.externalDiCode, externalDiCode) || other.externalDiCode == externalDiCode)&&const DeepCollectionEquality().equals(other._externalCodeImports, _externalCodeImports)&&(identical(other.externalCode, externalCode) || other.externalCode == externalCode)&&const DeepCollectionEquality().equals(other._appDependencies, _appDependencies));
}


@override
int get hashCode => Object.hash(runtimeType,packageName,const DeepCollectionEquality().hash(_coreDiImports),coreDiCode,const DeepCollectionEquality().hash(_externalDiImports),externalDiCode,const DeepCollectionEquality().hash(_externalCodeImports),externalCode,const DeepCollectionEquality().hash(_appDependencies));

@override
String toString() {
  return 'InfraTemplateSpec(packageName: $packageName, coreDiImports: $coreDiImports, coreDiCode: $coreDiCode, externalDiImports: $externalDiImports, externalDiCode: $externalDiCode, externalCodeImports: $externalCodeImports, externalCode: $externalCode, appDependencies: $appDependencies)';
}


}

/// @nodoc
abstract mixin class _$InfraTemplateSpecCopyWith<$Res> implements $InfraTemplateSpecCopyWith<$Res> {
  factory _$InfraTemplateSpecCopyWith(_InfraTemplateSpec value, $Res Function(_InfraTemplateSpec) _then) = __$InfraTemplateSpecCopyWithImpl;
@override @useResult
$Res call({
 String packageName, Set<String> coreDiImports, String? coreDiCode, Set<String> externalDiImports, String? externalDiCode, Set<String> externalCodeImports, String? externalCode, Set<String> appDependencies
});




}
/// @nodoc
class __$InfraTemplateSpecCopyWithImpl<$Res>
    implements _$InfraTemplateSpecCopyWith<$Res> {
  __$InfraTemplateSpecCopyWithImpl(this._self, this._then);

  final _InfraTemplateSpec _self;
  final $Res Function(_InfraTemplateSpec) _then;

/// Create a copy of InfraTemplateSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageName = null,Object? coreDiImports = null,Object? coreDiCode = freezed,Object? externalDiImports = null,Object? externalDiCode = freezed,Object? externalCodeImports = null,Object? externalCode = freezed,Object? appDependencies = null,}) {
  return _then(_InfraTemplateSpec(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,coreDiImports: null == coreDiImports ? _self._coreDiImports : coreDiImports // ignore: cast_nullable_to_non_nullable
as Set<String>,coreDiCode: freezed == coreDiCode ? _self.coreDiCode : coreDiCode // ignore: cast_nullable_to_non_nullable
as String?,externalDiImports: null == externalDiImports ? _self._externalDiImports : externalDiImports // ignore: cast_nullable_to_non_nullable
as Set<String>,externalDiCode: freezed == externalDiCode ? _self.externalDiCode : externalDiCode // ignore: cast_nullable_to_non_nullable
as String?,externalCodeImports: null == externalCodeImports ? _self._externalCodeImports : externalCodeImports // ignore: cast_nullable_to_non_nullable
as Set<String>,externalCode: freezed == externalCode ? _self.externalCode : externalCode // ignore: cast_nullable_to_non_nullable
as String?,appDependencies: null == appDependencies ? _self._appDependencies : appDependencies // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
