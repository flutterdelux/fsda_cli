import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../../core/extensions/enum_param_x.dart';
import '../../domain/params/enum_param.dart';
import '../templates/enum_template.dart';
import '../templates/feature_template.dart';
import 'helpers/arb_service.dart';
import 'helpers/directory_service.dart';
import 'helpers/export_service.dart';
import 'helpers/file_service.dart';
import 'helpers/operation_report_service.dart';

class EnumService {
  final OperationReportService _reportService;
  final ExportService _exportService;
  final ArbService _arbService;
  final DirectoryService _directoryService;
  final FileService _fileService;

  const EnumService({
    required OperationReportService reportService,
    required ExportService exportService,
    required ArbService arbService,
    required DirectoryService directoryService,
    required FileService fileService,
  }) : _reportService = reportService,
       _exportService = exportService,
       _arbService = arbService,
       _directoryService = directoryService,
       _fileService = fileService;

  Future<void> generateEnum({
    required EnumParam enumParam,
    required Function(String) onProgress,
  }) async {
    onProgress('Creating enum file...');
    await _createEnum(enumParam);

    onProgress('Injecting export enum file...');
    await _injectExportEnum(enumParam);

    onProgress('Creating enum converter file...');
    await _createEnumConverter(enumParam);

    onProgress('Creating enum extension file...');
    await _createEnumExtension(enumParam);

    onProgress('Injecting export enum extension file...');
    await _injectExportEnumExtension(enumParam);

    onProgress('Injecting localization keys into ARB files...');
    await _injectEnumArb(enumParam);
  }

  Future<void> removeEnum({
    required EnumParam enumParam,
    required Function(String) onProgress,
  }) async {
    onProgress('Removing enum file...');
    await _removeEnum(enumParam);

    onProgress('Unjecting export enum from feature barrel...');
    await _unjectExportEnum(enumParam);

    onProgress('Removing enum converter file...');
    await _removeEnumConverter(enumParam);

    onProgress('Removing enum extension file...');
    await _removeEnumExtension(enumParam);

    onProgress('Unjecting export enum extension from feature barrel...');
    await _unjectExportEnumExtension(enumParam);

    onProgress('Unjecting localization keys from ARB files...');
    await _unjectEnumArb(enumParam);
  }

  Future<List<String>> getValuesFromEnumFile(String enumPath) async {
    if (!await _fileService.exists(enumPath)) return [];

    final content = await _fileService.readAsString(enumPath);
    final result = parseString(content: content);
    final unit = result.unit;

    final values = <String>[];

    for (final declaration in unit.declarations) {
      // Memeriksa apakah deklarasi tersebut adalah sebuah EnumDeclaration di AST
      if (declaration is EnumDeclaration) {
        final body = declaration.body;
        for (final constant in body.constants) {
          final camelCaseValue = constant.name.lexeme;

          // Konversi kembali dari camelCase (inProgress) ke snake_case (in_progress)
          final snakeCaseValue = camelCaseValue
              .replaceAllMapped(
                RegExp(r'(?<=[a-z])[A-Z]'),
                (Match m) => '_${m.group(0)}',
              )
              .toLowerCase();

          values.add(snakeCaseValue);
        }
      }
    }
    return values;
  }

  // ================= Generate Helper ========================

  Future<void> _createEnum(EnumParam enumParam) async {
    final path = enumParam.path;
    final content = EnumTemplate.buildEnum(enumParam);
    await _directoryService.create(p.dirname(path));
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);
  }

  Future<void> _injectExportEnum(EnumParam enumParam) async {
    final barrelPath = enumParam.featureBarrelPath;
    await _exportService.inject(
      barrelPath: barrelPath,
      exportLines: ["export 'domain/enums/${enumParam.name}.dart';"],
      checkpoint: '// domain',
    );
    _reportService.addInjected(barrelPath);
  }

  Future<void> _createEnumConverter(EnumParam enumParam) async {
    final path = p.join(
      enumParam.featurePath,
      'data',
      'converters',
      '${enumParam.name}_converter.dart',
    );
    final content = EnumTemplate.buildConverter(enumParam);
    await _directoryService.create(p.dirname(path));
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);
  }

  Future<void> _createEnumExtension(EnumParam enumParam) async {
    final path = p.join(
      enumParam.featurePath,
      'ui',
      'shared',
      'extensions',
      '${enumParam.name}_x.dart',
    );
    final content = EnumTemplate.buildExtension(enumParam);
    await _directoryService.create(p.dirname(path));
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);
  }

  Future<void> _injectExportEnumExtension(EnumParam enumParam) async {
    final barrelPath = enumParam.featureBarrelPath;
    await _exportService.inject(
      barrelPath: barrelPath,
      exportLines: ["export 'ui/shared/extensions/${enumParam.name}_x.dart';"],
      checkpoint: '// ui',
    );
    _reportService.addInjected(barrelPath);
  }

  Future<void> _injectEnumArb(EnumParam enumParam) async {
    final arbPaths = await _arbService.getArbPaths(enumParam.modulePath);
    final arbEntries = EnumTemplate.buildArbEntries(enumParam);
    final endKey = FeatureTemplate.endDividerArbKey(enumParam.featureName);
    for (final arbPath in arbPaths) {
      await _arbService.injectEntriesBeforeKey(
        arbPath: arbPath,
        arbEntries: arbEntries,
        endKey: endKey,
      );
      _reportService.addInjected(arbPath);
    }
  }

  // ================= Remove Helper ========================

  Future<void> _removeEnum(EnumParam enumParam) async {
    await _fileService.delete(enumParam.path);
    _reportService.addRemoved(enumParam.path);
  }

  Future<void> _unjectExportEnum(EnumParam enumParam) async {
    final barrelPath = enumParam.featureBarrelPath;
    if (await _fileService.exists(barrelPath)) {
      await _exportService.unject(
        barrelPath: barrelPath,
        exportLines: ["export 'domain/enums/${enumParam.name}.dart';"],
      );
      _reportService.addUnjected(barrelPath);
    }
  }

  Future<void> _removeEnumConverter(EnumParam enumParam) async {
    final path = p.join(
      enumParam.featurePath,
      'data',
      'converters',
      '${enumParam.name}_converter.dart',
    );
    if (await _fileService.exists(path)) {
      await _fileService.delete(path);
      _reportService.addRemoved(path);
    }
  }

  Future<void> _removeEnumExtension(EnumParam enumParam) async {
    final path = p.join(
      enumParam.featurePath,
      'ui',
      'shared',
      'extensions',
      '${enumParam.name}_x.dart',
    );
    if (await _fileService.exists(path)) {
      await _fileService.delete(path);
      _reportService.addRemoved(path);
    }
  }

  Future<void> _unjectExportEnumExtension(EnumParam enumParam) async {
    final barrelPath = enumParam.featureBarrelPath;
    if (await _fileService.exists(barrelPath)) {
      await _exportService.unject(
        barrelPath: barrelPath,
        exportLines: [
          "export 'ui/shared/extensions/${enumParam.name}_x.dart';",
        ],
      );
      _reportService.addUnjected(barrelPath);
    }
  }

  Future<void> _unjectEnumArb(EnumParam enumParam) async {
    final arbPaths = await _arbService.getArbPaths(enumParam.modulePath);
    final arbEntries = EnumTemplate.buildArbEntries(enumParam);
    for (final arbPath in arbPaths) {
      await _arbService.unjectEntries(arbPath: arbPath, arbEntries: arbEntries);
      _reportService.addUnjected(arbPath);
    }
  }
}
