import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../../generators/base_generator.dart';
import '../memory_generator_target.dart';
import '../operation_report_service.dart';
import 'slice_checkpoint_weaver_service.dart';
import 'slice_manifest_render_service.dart';
import 'slice_source_normalizer_service.dart';

class SliceService extends BaseGenerator<void, Never> {
  final SliceManifestRenderService manifestRenderService;
  final SliceSourceNormalizerService sourceNormalizerService;
  final SliceCheckpointWeaverService checkpointWeaverService;

  SliceService({
    required super.logger,
    required super.fileService,
    required super.hookService,
    SliceManifestRenderService? manifestRenderService,
    SliceSourceNormalizerService? sourceNormalizerService,
    SliceCheckpointWeaverService? checkpointWeaverService,
  }) : manifestRenderService =
           manifestRenderService ?? const SliceManifestRenderService(),
       sourceNormalizerService =
           sourceNormalizerService ?? const SliceSourceNormalizerService(),
       checkpointWeaverService =
           checkpointWeaverService ??
           SliceCheckpointWeaverService(logger: logger);

  @override
  Future<void> generate(Never args) async {
    throw UnsupportedError(
      'Legacy generic slice generation is removed in v2. Use dedicated slice-* commands.',
    );
  }

  Future<void> generateVariant({
    required String operationLabel,
    required String successVerb,
    required String sequenceDescription,
    required bool isMutation,
    required String sliceName,
    required String featureName,
    required String moduleName,
    required String methodName,
    String? modelName,
    bool? isList,
    required MasonBundle bundle,
    required bool strict,
    required bool hookDisabled,
    String? paramPrefix,
    String? requestPrefix,
  }) async {
    if (fileService == null || hookService == null) {
      logger.error(
        'FileService and HookService are required for slice weaving.',
      );
      exitCode = 1;
      return;
    }

    logger.info(
      'Weaving slice "$sliceName" -> "$moduleName/$featureName" as $sequenceDescription sequence...',
    );
    final progress = logger.progress('Baking slice "$sliceName" in memory...');
    final memoryGeneratorTarget = MemoryGeneratorTarget();
    final report = OperationReportService();

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

      final paramRequestAliases = _resolveParamRequestAliases(
        featureName: featureName,
        sliceName: sliceName,
        paramPrefix: paramPrefix,
        requestPrefix: requestPrefix,
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
      final templateWriteResult = await fileService!.generateTemplate(
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
          return;
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

      if (postHooks.isNotEmpty) {
        progress.update('Running post hooks...');
        await hookService!.runHook(
          hooks: postHooks,
          workingDirectory: p.join(
            Directory.current.path,
            'modules',
            moduleName,
          ),
          logger: logger,
          disabled: hookDisabled,
          operationLabel: operationLabel,
        );
      }

      progress.complete(
        '$successVerb "$sliceName" successfully woven into "$featureName" feature! 🧵✨',
      );
      report.logSummary(logger, operationLabel: operationLabel);
    } catch (e) {
      progress.fail('Failed to stitch slice: $e');
      exitCode = 1;
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
    String? paramPrefix,
    String? requestPrefix,
  }) {
    if (paramPrefix == null || requestPrefix == null) {
      return null;
    }

    final normalizedParamPrefix = _stripKnownSuffix(paramPrefix, 'param');
    final normalizedRequestPrefix = _stripKnownSuffix(requestPrefix, 'request');

    if (normalizedParamPrefix.isEmpty || normalizedRequestPrefix.isEmpty) {
      return null;
    }

    final legacyPrefixSnake = '${featureName.snakeCase}_${sliceName.snakeCase}';

    return (
      oldParamClass: '${featureName.pascalCase}${sliceName.pascalCase}Param',
      oldParamFile: '${legacyPrefixSnake}_param.dart',
      newParamClass: '${normalizedParamPrefix.pascalCase}Param',
      newParamFile: '${normalizedParamPrefix.snakeCase}_param.dart',
      oldRequestClass:
          '${featureName.pascalCase}${sliceName.pascalCase}Request',
      oldRequestFile: '${legacyPrefixSnake}_request.dart',
      newRequestClass: '${normalizedRequestPrefix.pascalCase}Request',
      newRequestFile: '${normalizedRequestPrefix.snakeCase}_request.dart',
    );
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

  String _stripKnownSuffix(String raw, String suffix) {
    final value = raw.trim();
    if (value.isEmpty) {
      return value;
    }

    final lowerValue = value.toLowerCase();
    final lowerSuffix = suffix.toLowerCase();
    final snakeSuffix = '_$lowerSuffix';

    if (lowerValue.endsWith(snakeSuffix)) {
      return value.substring(0, value.length - snakeSuffix.length);
    }

    if (lowerValue.endsWith(lowerSuffix)) {
      return value.substring(0, value.length - lowerSuffix.length);
    }

    return value;
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
