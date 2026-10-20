import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../file_service.dart';
import '../logger_service.dart';
import '../memory_generator_target.dart';
import '../operation_report_service.dart';
import 'slice_checkpoint_weaver_service.dart';
import 'slice_manifest_render_service.dart';
import 'slice_source_normalizer_service.dart';

class SliceService {
  final LoggerService logger;
  final FileService fileService;
  final OperationReportService report;
  final SliceManifestRenderService manifestRenderService;
  final SliceSourceNormalizerService sourceNormalizerService;
  final SliceCheckpointWeaverService checkpointWeaverService;

  SliceService({
    required this.logger,
    required this.fileService,
    required this.report,
    required this.manifestRenderService,
    required this.sourceNormalizerService,
    required this.checkpointWeaverService,
  });

  Future<Map<String, dynamic>> generateVariant({
    required String operationLabel,
    required String successVerb,
    required String sequenceDescription,
    required bool isMutation,
    required String sliceName,
    required String featureName,
    required String moduleName,
    required String methodName,
    String? modelName,
    String? dtoName,
    String? entityName,
    bool? isList,
    required MasonBundle bundle,
    required bool strict,
    String? paramName,
    String? requestName,
  }) async {
    logger.info(
      'Weaving slice "$sliceName" -> "$moduleName/$featureName" as $sequenceDescription sequence...',
    );
    final progress = logger.progress('Baking slice "$sliceName" in memory...');
    final memoryGeneratorTarget = MemoryGeneratorTarget();

    try {
      final vars = _buildGeneratorVars(
        sliceName: sliceName,
        featureName: featureName,
        moduleName: moduleName,
        methodName: methodName,
        modelName: modelName,
        isList: isList,
      );

      final generator = await MasonGenerator.fromBundle(bundle);
      await generator.generate(memoryGeneratorTarget, vars: vars);

      String? sequenceYamlRaw;
      final standaloneFilesToSave = <String, List<int>>{};

      for (final entry in memoryGeneratorTarget.files.entries) {
        final filePath = entry.key;
        final fileBytes = entry.value;
        final fileName = p.basename(filePath);

        if (fileName == 'sequence.yaml') {
          sequenceYamlRaw = utf8.decode(fileBytes);
          continue;
        }

        standaloneFilesToSave[filePath] = fileBytes;
      }

      if (sequenceYamlRaw == null) {
        throw Exception('sequence.yaml not found in generated slice files.');
      }

      var renderedSequenceYaml = manifestRenderService.renderSequenceManifest(
        template: sequenceYamlRaw,
        vars: vars,
      );

      final entityDtoAliases = _resolveEntityDtoAliases(
        modelName: modelName,
        dtoName: dtoName,
        entityName: entityName,
      );
      if (entityDtoAliases != null) {
        _rewriteStandaloneEntityDtoReferences(
          files: standaloneFilesToSave,
          aliases: entityDtoAliases,
        );
        renderedSequenceYaml = _rewriteManifestEntityDtoReferences(
          source: renderedSequenceYaml,
          aliases: entityDtoAliases,
        );
      }

      final paramRequestAliases = _resolveParamRequestAliases(
        featureName: featureName,
        sliceName: sliceName,
        paramName: paramName,
        requestName: requestName,
      );
      if (paramRequestAliases != null) {
        _rewriteStandaloneParamRequestReferences(
          files: standaloneFilesToSave,
          aliases: paramRequestAliases,
        );
        renderedSequenceYaml = _rewriteManifestParamRequestReferences(
          source: renderedSequenceYaml,
          aliases: paramRequestAliases,
        );
      }

      sourceNormalizerService.normalizeStandaloneDartFiles(
        standaloneFilesToSave,
      );

      final featureRoot = p.join(
        Directory.current.path,
        'modules',
        moduleName,
        'lib',
        'src',
        'features',
        featureName,
      );

      progress.update('Writing standalone slice files to disk...');
      final templateWriteResult = await fileService.generateTemplate(
        path: featureRoot,
        files: standaloneFilesToSave,
        failOnExisting: strict,
      );

      report.addCreatedTemplateFiles(
        targetRoot: featureRoot,
        relativeFiles: templateWriteResult.writtenFiles,
      );
      report.addSkippedTemplateFiles(
        targetRoot: featureRoot,
        relativeFiles: templateWriteResult.skippedFiles,
      );

      if (templateWriteResult.skippedCount > 0) {
        logger.info(
          'Skipped ${templateWriteResult.skippedCount} existing slice file(s) to prevent overwrite.',
        );

        if (strict || templateWriteResult.abortedDueToExisting) {
          logger.error(
            'Strict mode: generation aborted because some slice files already exist.',
          );
          report.logSummary(logger, operationLabel: operationLabel);
          exitCode = 1;
          return <String, dynamic>{'success': false};
        }
      }

      progress.update('Parsing sequence manifest & weaving checkpoint...');
      final doc = loadYaml(renderedSequenceYaml) as YamlMap;

      final remoteDsContract = checkpointWeaverService.readSection(
        manifest: doc,
        key: 'remote_data_source_contract',
      );
      final remoteDsImpl = checkpointWeaverService.readSection(
        manifest: doc,
        key: 'remote_data_source_impl',
      );
      final localDsContract = checkpointWeaverService.readSection(
        manifest: doc,
        key: 'local_data_source_contract',
      );
      final localDsImpl = checkpointWeaverService.readSection(
        manifest: doc,
        key: 'local_data_source_impl',
      );
      final repoContract = checkpointWeaverService.readSection(
        manifest: doc,
        key: 'repository_contract',
      );
      final repoImpl = checkpointWeaverService.readSection(
        manifest: doc,
        key: 'repository_impl',
      );
      final exportMap = doc['export'] as YamlMap?;
      final postHooks = checkpointWeaverService.normalizePostHooks(
        List<String>.from(doc['post_hooks'] as List? ?? const []),
      );

      final remoteContractPath = p.join(
        featureRoot,
        'data',
        'datasources',
        '${featureName}_remote_data_source.dart',
      );
      final remoteContractChanged = await checkpointWeaverService
          .injectDataSourceSection(
            section: remoteDsContract,
            sectionName: 'remote_data_source_contract',
            path: remoteContractPath,
            isMutation: isMutation,
            strict: strict,
          );
      if (remoteContractChanged) {
        report.addInjected(remoteContractPath);
      }

      final remoteImplPath = p.join(
        featureRoot,
        'data',
        'datasources',
        '${featureName}_remote_data_source_impl.dart',
      );
      final remoteImplChanged = await checkpointWeaverService
          .injectDataSourceSection(
            section: remoteDsImpl,
            sectionName: 'remote_data_source_impl',
            path: remoteImplPath,
            isMutation: isMutation,
            strict: strict,
          );
      if (remoteImplChanged) {
        report.addInjected(remoteImplPath);
      }

      final localContractPath = p.join(
        featureRoot,
        'data',
        'datasources',
        '${featureName}_local_data_source.dart',
      );
      final localContractChanged = await checkpointWeaverService
          .injectDataSourceSection(
            section: localDsContract,
            sectionName: 'local_data_source_contract',
            path: localContractPath,
            isMutation: isMutation,
            strict: strict,
          );
      if (localContractChanged) {
        report.addInjected(localContractPath);
      }

      final localImplPath = p.join(
        featureRoot,
        'data',
        'datasources',
        '${featureName}_local_data_source_impl.dart',
      );
      final localImplChanged = await checkpointWeaverService
          .injectDataSourceSection(
            section: localDsImpl,
            sectionName: 'local_data_source_impl',
            path: localImplPath,
            isMutation: isMutation,
            strict: strict,
          );
      if (localImplChanged) {
        report.addInjected(localImplPath);
      }

      final repoContractPath = p.join(
        featureRoot,
        'domain',
        'repositories',
        '${featureName}_repository.dart',
      );
      final repoContractImportChanged = await checkpointWeaverService
          .injectImports(path: repoContractPath, imports: repoContract.imports);
      final repoContractCodeChanged = await checkpointWeaverService.injectCode(
        path: repoContractPath,
        code: repoContract.code,
        isMutation: isMutation,
        strict: strict,
      );
      if (repoContractImportChanged || repoContractCodeChanged) {
        report.addInjected(repoContractPath);
      }

      final repoImplPath = p.join(
        featureRoot,
        'data',
        'repositories',
        '${featureName}_repository_impl.dart',
      );
      final repoImplImportChanged = await checkpointWeaverService.injectImports(
        path: repoImplPath,
        imports: repoImpl.imports,
      );
      final repoImplCodeChanged = await checkpointWeaverService.injectCode(
        path: repoImplPath,
        code: repoImpl.code,
        isMutation: isMutation,
        strict: strict,
      );
      if (repoImplImportChanged || repoImplCodeChanged) {
        report.addInjected(repoImplPath);
      }

      if (exportMap != null && exportMap.isNotEmpty) {
        progress.update('Registering export to feature barrel...');
        final featureBarrelPath = p.join(
          featureRoot,
          '${featureName}_feature.dart',
        );
        final barrelChanged = await checkpointWeaverService
            .updateFeatureBarrelStructured(
              path: featureBarrelPath,
              exportMap: exportMap,
            );
        if (barrelChanged) {
          report.addUpdated(featureBarrelPath);
        }
      }

      progress.complete(
        '$successVerb "$sliceName" successfully woven into "$featureName" feature! 🧵✨',
      );
      report.logSummary(logger, operationLabel: operationLabel);

      return <String, dynamic>{
        'success': true,
        if (postHooks.isNotEmpty) 'post_hook': postHooks,
        'working_directory': p.join(
          Directory.current.path,
          'modules',
          moduleName,
        ),
      };
    } catch (e) {
      progress.fail('Failed to stitch slice: $e');
      exitCode = 1;
      return <String, dynamic>{'success': false};
    }
  }

  ({
    String oldParamClass,
    String oldParamFile,
    String newParamClass,
    String newParamFile,
    String oldRequestClass,
    String oldRequestFile,
    String newRequestClass,
    String newRequestFile,
  })?
  _resolveParamRequestAliases({
    required String featureName,
    required String sliceName,
    String? paramName,
    String? requestName,
  }) {
    if (paramName == null || requestName == null) {
      return null;
    }

    if (paramName.isEmpty || requestName.isEmpty) {
      return null;
    }

    final legacyPrefixSnake = '${featureName.snakeCase}_${sliceName.snakeCase}';

    return (
      oldParamClass: '${featureName.pascalCase}${sliceName.pascalCase}Param',
      oldParamFile: '${legacyPrefixSnake}_param.dart',
      newParamClass: paramName.pascalCase,
      newParamFile: '${paramName.snakeCase}.dart',
      oldRequestClass:
          '${featureName.pascalCase}${sliceName.pascalCase}Request',
      oldRequestFile: '${legacyPrefixSnake}_request.dart',
      newRequestClass: requestName.pascalCase,
      newRequestFile: '${requestName.snakeCase}.dart',
    );
  }

  ({
    String oldDtoClass,
    String oldDtoFile,
    String newDtoClass,
    String newDtoFile,
    String oldEntityClass,
    String oldEntityFile,
    String newEntityClass,
    String newEntityFile,
  })?
  _resolveEntityDtoAliases({
    String? modelName,
    String? dtoName,
    String? entityName,
  }) {
    if (modelName == null || dtoName == null || entityName == null) {
      return null;
    }

    final modelSnake = modelName.snakeCase;
    return (
      oldDtoClass: '${modelName}Dto',
      oldDtoFile: '${modelSnake}_dto.dart',
      newDtoClass: dtoName.pascalCase,
      newDtoFile: '${dtoName.snakeCase}.dart',
      oldEntityClass: '${modelName}Entity',
      oldEntityFile: '${modelSnake}_entity.dart',
      newEntityClass: entityName.pascalCase,
      newEntityFile: '${entityName.snakeCase}.dart',
    );
  }

  void _rewriteStandaloneEntityDtoReferences({
    required Map<String, List<int>> files,
    required ({
      String oldDtoClass,
      String oldDtoFile,
      String newDtoClass,
      String newDtoFile,
      String oldEntityClass,
      String oldEntityFile,
      String newEntityClass,
      String newEntityFile,
    })
    aliases,
  }) {
    for (final entry in files.entries.toList(growable: false)) {
      if (!entry.key.endsWith('.dart')) continue;
      final source = utf8.decode(entry.value);
      final rewritten = _replaceLegacyEntityDtoReferences(
        source: source,
        aliases: aliases,
      );
      if (rewritten != source) {
        files[entry.key] = utf8.encode(rewritten);
      }
    }
  }

  String _rewriteManifestEntityDtoReferences({
    required String source,
    required ({
      String oldDtoClass,
      String oldDtoFile,
      String newDtoClass,
      String newDtoFile,
      String oldEntityClass,
      String oldEntityFile,
      String newEntityClass,
      String newEntityFile,
    })
    aliases,
  }) {
    return _replaceLegacyEntityDtoReferences(source: source, aliases: aliases);
  }

  String _replaceLegacyEntityDtoReferences({
    required String source,
    required ({
      String oldDtoClass,
      String oldDtoFile,
      String newDtoClass,
      String newDtoFile,
      String oldEntityClass,
      String oldEntityFile,
      String newEntityClass,
      String newEntityFile,
    })
    aliases,
  }) {
    return source
        .replaceAll(aliases.oldDtoClass, aliases.newDtoClass)
        .replaceAll(aliases.oldEntityClass, aliases.newEntityClass)
        .replaceAll(aliases.oldDtoFile, aliases.newDtoFile)
        .replaceAll(aliases.oldEntityFile, aliases.newEntityFile);
  }

  void _rewriteStandaloneParamRequestReferences({
    required Map<String, List<int>> files,
    required ({
      String oldParamClass,
      String oldParamFile,
      String newParamClass,
      String newParamFile,
      String oldRequestClass,
      String oldRequestFile,
      String newRequestClass,
      String newRequestFile,
    })
    aliases,
  }) {
    for (final entry in files.entries.toList(growable: false)) {
      final filePath = entry.key;
      if (!filePath.endsWith('.dart')) {
        continue;
      }

      final source = utf8.decode(entry.value);
      final rewritten = _replaceLegacyParamRequestReferences(
        source: source,
        aliases: aliases,
      );
      if (rewritten != source) {
        files[filePath] = utf8.encode(rewritten);
      }
    }
  }

  String _rewriteManifestParamRequestReferences({
    required String source,
    required ({
      String oldParamClass,
      String oldParamFile,
      String newParamClass,
      String newParamFile,
      String oldRequestClass,
      String oldRequestFile,
      String newRequestClass,
      String newRequestFile,
    })
    aliases,
  }) {
    return _replaceLegacyParamRequestReferences(
      source: source,
      aliases: aliases,
    );
  }

  String _replaceLegacyParamRequestReferences({
    required String source,
    required ({
      String oldParamClass,
      String oldParamFile,
      String newParamClass,
      String newParamFile,
      String oldRequestClass,
      String oldRequestFile,
      String newRequestClass,
      String newRequestFile,
    })
    aliases,
  }) {
    return source
        .replaceAll(aliases.oldParamClass, aliases.newParamClass)
        .replaceAll(aliases.oldRequestClass, aliases.newRequestClass)
        .replaceAll(aliases.oldParamFile, aliases.newParamFile)
        .replaceAll(aliases.oldRequestFile, aliases.newRequestFile);
  }

  Map<String, dynamic> _buildGeneratorVars({
    required String sliceName,
    required String featureName,
    required String moduleName,
    required String methodName,
    String? modelName,
    bool? isList,
  }) {
    return <String, dynamic>{
      'slice': sliceName,
      'feature': featureName,
      'module': moduleName,
      'method': methodName,
      ...?(modelName != null ? <String, dynamic>{'model': modelName} : null),
      ...?(isList != null ? <String, dynamic>{'is_list': isList} : null),
    };
  }
}
