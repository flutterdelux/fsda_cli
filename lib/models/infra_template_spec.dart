import 'package:freezed_annotation/freezed_annotation.dart';

part 'infra_template_spec.freezed.dart';

@freezed
abstract class InfraTemplateSpec with _$InfraTemplateSpec {
  const factory InfraTemplateSpec({
    required String packageName,
    required Set<String> coreDiImports,
    String? coreDiCode,
    required Set<String> externalDiImports,
    String? externalDiCode,
    required Set<String> externalCodeImports,
    String? externalCode,
    required Set<String> appDependencies,
  }) = _InfraTemplateSpec;
}
