import '../../core/extensions/input_gate_param_x.dart';
import '../../domain/params/inputs/input_dropdown_enum_param.dart';
import '../../domain/params/inputs/input_dropdown_param.dart';
import '../../domain/params/inputs/input_image_param.dart';
import '../../domain/params/inputs/input_number_param.dart';
import '../../domain/params/inputs/input_password_param.dart';
import '../../domain/params/inputs/input_qty_param.dart';
import '../../domain/params/inputs/input_selector_param.dart';
import '../../domain/params/inputs/input_switch_param.dart';
import '../../domain/params/inputs/input_text_area_param.dart';
import '../../domain/params/inputs/input_text_param.dart';
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

  Future<void> generateText({
    required InputTextParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating widget...');
    final content = InputTextTemplate.build(input);
    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    onProgress('Injecting localization entries...');
    await _injectArb(
      modulePath: input.modulePath,
      featureName: input.featureName,
      arbEntries: InputTextTemplate.buildArbEntries(input),
    );
  }

  Future<void> generateTextArea({
    required InputTextAreaParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating text area widget...');
    final content = InputTextAreaTemplate.build(input);
    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    onProgress('Injecting localization entries...');
    await _injectArb(
      modulePath: input.modulePath,
      featureName: input.featureName,
      arbEntries: InputTextAreaTemplate.buildArbEntries(input),
    );
  }

  Future<void> generateNumber({
    required InputNumberParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating widget...');
    final content = InputNumberTemplate.build(input);
    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    onProgress('Resolving and injecting import references to widget file...');
    final imports = await _importResolverService.resolve(
      rawTypes: {input.type},
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

    onProgress('Injecting localization entries...');
    await _injectArb(
      modulePath: input.modulePath,
      featureName: input.featureName,
      arbEntries: InputNumberTemplate.buildArbEntries(input),
    );
  }

  Future<void> generateSwitch({
    required InputSwitchParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating switch widget...');
    final content = InputSwitchTemplate.build(input);
    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    onProgress('Injecting localization entries...');
    await _injectArb(
      modulePath: input.modulePath,
      featureName: input.featureName,
      arbEntries: InputSwitchTemplate.buildArbEntries(input),
    );
  }

  Future<void> generatePassword({
    required InputPasswordParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating widget...');
    final content = InputPasswordTemplate.build(input);
    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    onProgress('Injecting localization entries...');
    await _injectArb(
      modulePath: input.modulePath,
      featureName: input.featureName,
      arbEntries: InputPasswordTemplate.buildArbEntries(input),
    );
  }

  Future<void> generateQty({
    required InputQtyParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating widget...');
    final content = InputQtyTemplate.build(input);
    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    onProgress('Injecting localization entries...');
    await _injectArb(
      modulePath: input.modulePath,
      featureName: input.featureName,
      arbEntries: InputQtyTemplate.buildArbEntries(input),
    );
  }

  Future<void> generateImage({
    required InputImageParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating widget...');
    final content = InputImageTemplate.build(input);
    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    onProgress('Resolving and injecting import references to widget file...');
    final imports = await _importResolverService.resolve(
      rawTypes: {input.type},
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

    onProgress('Injecting localization entries...');
    await _injectArb(
      modulePath: input.modulePath,
      featureName: input.featureName,
      arbEntries: InputImageTemplate.buildArbEntries(input),
    );
  }

  Future<void> generateDropdown({
    required InputDropdownParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating widget...');
    final content = InputDropdownTemplate.build(input);
    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    onProgress('Resolving and injecting import references to widget file...');
    final imports = await _importResolverService.resolve(
      rawTypes: {input.type},
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

    onProgress('Injecting localization entries...');
    await _injectArb(
      modulePath: input.modulePath,
      featureName: input.featureName,
      arbEntries: InputDropdownTemplate.buildArbEntries(input),
    );
  }

  Future<void> generateDropdownEnum({
    required InputDropdownEnumParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating widget...');
    final content = InputDropdownEnumTemplate.build(input);
    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    onProgress('Resolving and injecting import references to widget file...');
    final imports = await _importResolverService.resolve(
      rawTypes: {input.type},
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

    onProgress('Injecting localization entries...');
    await _injectArb(
      modulePath: input.modulePath,
      featureName: input.featureName,
      arbEntries: InputDropdownEnumTemplate.buildArbEntries(input),
    );
  }

  Future<void> generateSelector({
    required InputSelectorParam input,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Creating widget...');
    final content = input.isList
        ? InputSelectorListTemplate.build(input)
        : InputSelectorTemplate.build(input);

    await _fileService.writeAsString(path: input.widgetPath, content: content);
    _reportService.addCreated(input.widgetPath);

    onProgress('Resolving and injecting import references to widget file...');
    final imports = await _importResolverService.resolve(
      rawTypes: {input.valueType},
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

    onProgress('Injecting localization entries...');
    final arbEntries = input.isList
        ? InputSelectorListTemplate.buildArbEntries(input)
        : InputSelectorTemplate.buildArbEntries(input);

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
