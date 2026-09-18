import 'package:mason/mason.dart';

String buildImageInputTemplate({
  required String moduleName,
  required String featureName,
  required String fieldName,
  required String valueType,
}) {
  final featurePascal = featureName.pascalCase;
  final fieldPascal = fieldName.pascalCase;
  final modulePascal = moduleName.pascalCase;
  final className = '$featurePascal${fieldPascal}Field';
  final l10nKey = '${featureName.camelCase}Field$fieldPascal';
  final normalizedType = valueType.replaceAll(' ', '').replaceAll('?', '');
  final isNetworkFile = normalizedType == 'NetworkFile';
  final valueImport = isNetworkFile
      ? "import 'package:app_core/app_core.dart';"
      : "import '../../../domain/entities/${valueType.snakeCase}.dart';";
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

import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';
$valueImport

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
