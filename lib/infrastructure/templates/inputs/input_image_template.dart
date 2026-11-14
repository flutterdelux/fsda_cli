import '../../../domain/params/inputs/input_image_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class InputImageTemplate {
  static String build(InputImageParam input) {
    final featurePascal = input.featureName.pascalCase;
    final fieldPascal = input.field.pascalCase;
    final modulePascal = input.moduleName.pascalCase;
    final className = '$featurePascal${fieldPascal}Field';
    final l10nKey = '${input.featureName.camelCase}Field$fieldPascal';
    final valueType = input.type;
    final normalizedType = valueType.replaceAll(' ', '').replaceAll('?', '');
    final isNetworkFile = normalizedType == 'NetworkFile';
    final previewBytesAccess = isNetworkFile
        ? 'selectedValue!.bytes'
        : 'selectedValue!.file.bytes';
    final fileNameAccess = isNetworkFile
        ? 'selectedValue?.name'
        : 'selectedValue?.file.name';
    final keyAccess = isNetworkFile
        ? 'selectedValue?.bytes'
        : 'selectedValue?.file.bytes';

    return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${input.moduleName}_localizations.dart';

class $className extends StatelessWidget {
  final $valueType? selectedValue;
  final Future<void> Function($valueType? currentSelected)? onSelect;
  final VoidCallback? onClear;
  final String? initialUrl;

  const $className({
    super.key,
    required this.selectedValue,
    this.onSelect,
    this.onClear,
    this.initialUrl,
  });

  void _showImagePreview(BuildContext context) {
    if (selectedValue == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(child: Image.memory($previewBytesAccess)),
    );
  }

  void _handleSelect() => onSelect?.call(selectedValue);

  @override
  Widget build(BuildContext context) {
    final l10n = ${modulePascal}Localizations.of(context)!;
    return AppSection(
      header: AppSectionHeader(titleText: l10n.${l10nKey}Label),
      child: AppTextField(
        key: ValueKey($keyAccess),
        initialValue: $fileNameAccess ?? initialUrl?.split('/').last,
        hintText: l10n.${l10nKey}Hint,
        readOnly: true,
        onTap: _handleSelect,
        prefix: selectedValue == null
            ? initialUrl != null
                  ? UnconstrainedBox(
                      child: GestureDetector(
                        onTap: () => _showImagePreview(context),
                        child: AppNetworkImage(
                          url: initialUrl!,
                          shape: BoxShape.circle,
                          width: 36,
                          height: 36,
                        ),
                      ),
                    )
                  : null
            : UnconstrainedBox(
                child: GestureDetector(
                  onTap: () => _showImagePreview(context),
                  child: ClipOval(
                    child: Image.memory(
                      $previewBytesAccess,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
        suffix: UnconstrainedBox(
          child: AppInputFieldAction(
            hasValue: selectedValue != null,
            onClear: onClear,
            onPressed: _handleSelect,
            icon: Icons.image,
          ),
        ),
      ),
    );
  }
}
''';
  }

  static Map<String, dynamic> buildArbEntries(InputImageParam input) {
    final entries = <String, dynamic>{};
    final featureCamel = input.featureName.camelCase;
    final fieldPascal = input.field.pascalCase;
    final fieldTitle = input.field.titleCase;

    final key = '${featureCamel}Field$fieldPascal';
    entries['${key}Label'] = fieldTitle;
    entries['${key}Hint'] = 'Select $fieldTitle...';
    entries['${key}InvalidEmpty'] = '$fieldTitle cannot be empty';

    return entries;
  }
}
