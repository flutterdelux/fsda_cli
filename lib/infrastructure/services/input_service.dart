import '../../core/extensions/input_param_x.dart';
import '../../core/extensions/module_param_x.dart';
import '../../domain/enums/input_type.dart';
import '../../domain/params/input_param.dart';
import '../templates/feature_template.dart';
import '../templates/inputs/input_dropdown_enum_template.dart';
import '../templates/inputs/input_dropdown_template.dart';
import '../templates/inputs/input_image_template.dart';
import '../templates/inputs/input_number_template.dart';
import '../templates/inputs/input_password_template.dart';
import '../templates/inputs/input_qty_template.dart';
import '../templates/inputs/input_selector_list_template.dart';
import '../templates/inputs/input_selector_template.dart';
import '../templates/inputs/input_switch_template.dart';
import '../templates/inputs/input_text_area_template.dart';
import '../templates/inputs/input_text_template.dart';
import 'helpers/arb_service.dart';
import 'helpers/file_service.dart';
import 'helpers/import_resolver_service.dart';
import 'helpers/import_service.dart';
import 'helpers/operation_report_service.dart';

class InputService {
  final OperationReportService _reportService;
  final FileService _fileService;
  final ArbService _arbService;
  final ImportResolverService _importResolverService;
  final ImportService _importService;

  const InputService({
    required OperationReportService reportService,
    required FileService fileService,
    required ArbService arbService,
    required ImportResolverService importResolverService,
    required ImportService importService,
  }) : _reportService = reportService,
       _fileService = fileService,
       _arbService = arbService,
       _importResolverService = importResolverService,
       _importService = importService;

  Future<void> generate({
    required InputParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating ${input.type.code} input widget...');

    final content = switch (input.type) {
      InputType.text => InputTextTemplate.build(input),
      InputType.textArea => InputTextAreaTemplate.build(input),
      InputType.number => InputNumberTemplate.build(input),
      InputType.swich => InputSwitchTemplate.build(input),
      InputType.password => InputPasswordTemplate.build(input),
      InputType.qty => InputQtyTemplate.build(input),
      InputType.image => InputImageTemplate.build(input),
      InputType.dropdown => InputDropdownTemplate.build(input),
      InputType.dropdownEnum => InputDropdownEnumTemplate.build(input),
      InputType.selector =>
        input.isList
            ? InputSelectorListTemplate.build(input)
            : InputSelectorTemplate.build(input),
    };

    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    final dataType = input.dataType;
    if (dataType != null && dataType.isNotEmpty) {
      onProgress('Resolving and injecting import references to widget file...');
      final imports = await _importResolverService.resolve(
        rawTypes: {dataType},
        targetFilePath: input.widgetPath,
        modulePath: input.modulePath,
      );
      if (imports.isNotEmpty) {
        await _importService.injectImport(
          path: input.widgetPath,
          imports: imports,
        );
        _reportService.addInjected(input.widgetPath);
      }
    }

    onProgress('Injecting localization entries...');
    final arbEntries = switch (input.type) {
      InputType.text => InputTextTemplate.buildArbEntries(input),
      InputType.textArea => InputTextAreaTemplate.buildArbEntries(input),
      InputType.number => InputNumberTemplate.buildArbEntries(input),
      InputType.swich => InputSwitchTemplate.buildArbEntries(input),
      InputType.password => InputPasswordTemplate.buildArbEntries(input),
      InputType.qty => InputQtyTemplate.buildArbEntries(input),
      InputType.image => InputImageTemplate.buildArbEntries(input),
      InputType.dropdown => InputDropdownTemplate.buildArbEntries(input),
      InputType.dropdownEnum => InputDropdownEnumTemplate.buildArbEntries(
        input,
      ),
      InputType.selector =>
        input.isList
            ? InputSelectorListTemplate.buildArbEntries(input)
            : InputSelectorTemplate.buildArbEntries(input),
    };

    await _injectArb(
      modulePath: input.modulePath,
      featureName: input.featureName,
      arbEntries: arbEntries,
    );
  }

  // ========= Share Helper Inject Arb ==========
  Future<void> _injectArb({
    required String modulePath,
    required String featureName,
    required Map<String, dynamic> arbEntries,
  }) async {
    final arbPaths = await _arbService.getArbPaths(modulePath);
    for (final path in arbPaths) {
      await _arbService.injectEntriesBeforeKey(
        arbPath: path,
        endKey: FeatureTemplate.endDividerArbKey(featureName),
        arbEntries: arbEntries,
      );
      _reportService.addInjected(path);
    }
  }
}
