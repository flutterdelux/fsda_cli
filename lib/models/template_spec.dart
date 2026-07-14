import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml/yaml.dart';

part 'template_spec.freezed.dart';

@freezed
abstract class TemplateSpec with _$TemplateSpec {
  const TemplateSpec._();

  const factory TemplateSpec({
    required List<String> dependencies,
    required List<String> devDependencies,
    required List<String> postHooks,
  }) = _TemplateSpec;

  factory TemplateSpec.fromYaml(YamlMap yaml) {
    return TemplateSpec(
      dependencies: (yaml['dependencies'] as YamlList?)?.cast<String>() ?? [],
      devDependencies:
          (yaml['dev_dependencies'] as YamlList?)?.cast<String>() ?? [],
      postHooks: (yaml['post_hooks'] as YamlList?)?.cast<String>() ?? [],
    );
  }
}
