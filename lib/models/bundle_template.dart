import 'package:freezed_annotation/freezed_annotation.dart';

import 'template_spec.dart';

part 'bundle_template.freezed.dart';

@freezed
abstract class BundleTemplate with _$BundleTemplate {
  const factory BundleTemplate({
    required Map<String, List<int>> files,
    required TemplateSpec spec,
  }) = _BundleTemplate;
}
