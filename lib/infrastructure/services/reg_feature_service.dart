import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../../core/extensions/feature_param_x.dart';
import '../../core/extensions/module_param_x.dart';
import '../../core/extensions/reg_module_param_x.dart';
import '../../domain/models/dependency_metadata.dart';
import '../../domain/models/feature_metadata.dart';
import '../../domain/params/app_integration/reg_feature_param.dart';
import '../templates/app_integration/module_di_template.dart';
import '../templates/app_integration/module_route_template.dart';
import '../visitors/constructor_param_visitor.dart';
import '../visitors/last_getter_visitor.dart';
import 'helpers/directory_service.dart';
import 'helpers/file_service.dart';
import 'helpers/operation_report_service.dart';

class RegFeatureService {
  final OperationReportService _reportService;
  final FileService _fileService;
  final DirectoryService _directoryService;

  const RegFeatureService({
    required OperationReportService reportService,
    required FileService fileService,
    required DirectoryService directoryService,
  }) : _reportService = reportService,
       _fileService = fileService,
       _directoryService = directoryService;

  Future<void> registerFeature({
    required RegFeatureParam param,
    required void Function(String) onProgress,
  }) async {
    onProgress('Scaffolding feature pages and widgets directories...');
    await _scaffoldFeatureFolders(param);

    onProgress('Inspecting feature files in module...');
    final metadata = await _inspectFeatureMetadata(param);

    onProgress('Injecting feature DI registrations into module DI...');
    await _injectFeatureDi(param, metadata);

    onProgress('Injecting feature routes into module route...');
    await _injectFeatureRoute(param);
  }

  // ================= 1. Scaffold Folders =================

  Future<void> _scaffoldFeatureFolders(RegFeatureParam param) async {
    final dirPaths = [
      p.join(param.appModulePath, 'features', param.featureName, 'pages'),
      p.join(param.appModulePath, 'features', param.featureName, 'widgets'),
    ];
    for (final path in dirPaths) {
      if (await _directoryService.exists(path)) {
        _reportService.addSkipped(path);
        continue;
      }
      await _directoryService.create(path);
      _reportService.addCreated(path);
    }
  }

  // ================= Inspect Feature Metadata =================

  Future<FeatureMetadata> _inspectFeatureMetadata(RegFeatureParam param) async {
    final datasources = <DependencyMetadata>[];
    final repositories = <DependencyMetadata>[];
    final useCases = <DependencyMetadata>[];
    final logics = <DependencyMetadata>[];

    // Inspect Datasources (mengambil dari folder data/datasources, termasuk file _impl.dart jika ada)
    final dsPath = p.join(param.featurePath, 'data', 'datasources');
    if (await _directoryService.exists(dsPath)) {
      final files = await _directoryService.listPaths(
        dirPath: dsPath,
        where: (fileSystem, isFile) {
          return isFile && fileSystem.path.endsWith('.dart');
        },
      );
      for (final filePath in files) {
        final content = await _fileService.readAsString(filePath);
        try {
          final unit = parseString(content: content).unit;
          final visitor = ConstructorParamVisitor();
          unit.visitChildren(visitor);
          // Hanya masukkan kelas yang berakhiran Impl atau sesuai kebutuhan datasource
          if (visitor.className != null &&
              visitor.className!.endsWith('Impl')) {
            datasources.add(
              DependencyMetadata(
                className: visitor.className!,
                parameters: visitor.parameters,
              ),
            );
          }
        } catch (_) {}
      }
    }

    // Inspect Repositories (mencari file _impl.dart atau file di repositories)
    final repoPath = p.join(param.featurePath, 'data', 'repositories');
    if (await _directoryService.exists(repoPath)) {
      final files = await _directoryService.listPaths(
        dirPath: repoPath,
        where: (fileSystem, isFile) =>
            isFile && fileSystem.path.endsWith('.dart'),
      );
      for (final filePath in files) {
        final content = await _fileService.readAsString(filePath);
        try {
          final unit = parseString(content: content).unit;
          final visitor = ConstructorParamVisitor();
          unit.visitChildren(visitor);
          if (visitor.className != null) {
            repositories.add(
              DependencyMetadata(
                className: visitor.className!,
                parameters: visitor.parameters,
              ),
            );
          }
        } catch (_) {}
      }
    }

    // Inspect UseCases (domain/usecases)
    final ucPath = p.join(param.featurePath, 'domain', 'usecases');
    if (await _directoryService.exists(ucPath)) {
      final files = await _directoryService.listPaths(
        dirPath: ucPath,
        where: (fileSystem, isFile) =>
            isFile && fileSystem.path.endsWith('.dart'),
      );
      for (final filePath in files) {
        final content = await _fileService.readAsString(filePath);
        try {
          final unit = parseString(content: content).unit;
          final visitor = ConstructorParamVisitor();
          unit.visitChildren(visitor);
          if (visitor.className != null) {
            useCases.add(
              DependencyMetadata(
                className: visitor.className!,
                parameters: visitor.parameters,
              ),
            );
          }
        } catch (_) {}
      }
    }

    // Inspect Logic dengan struktur folder slice (logic/<slice_folder>/...)
    final logicPath = p.join(param.featurePath, 'logic');
    final logicSuffix = ['_cubit', '_controller', '_provider', '_bloc'];

    if (await _directoryService.exists(logicPath)) {
      // 1. Ambil semua sub-folder (slice categories) di dalam folder logic
      final sliceDirs = await _directoryService.listPaths(
        dirPath: logicPath,
        where: (fileSystem, isFile) => !isFile,
      );

      for (final sliceDir in sliceDirs) {
        // 2. List file-file di dalam sub-folder slice tersebut
        final files = await _directoryService.listPaths(
          dirPath: sliceDir,
          where: (fileSystem, isFile) {
            return isFile &&
                logicSuffix.any(
                  (suffix) => fileSystem.path.endsWith('$suffix.dart'),
                );
          },
        );

        // 3. Eksekusi AST parsing untuk setiap file logic yang ditemukan
        for (final filePath in files) {
          final content = await _fileService.readAsString(filePath);
          try {
            final unit = parseString(content: content).unit;
            final visitor = ConstructorParamVisitor();
            unit.visitChildren(visitor);
            if (visitor.className != null) {
              logics.add(
                DependencyMetadata(
                  className: visitor.className!,
                  parameters: visitor.parameters,
                ),
              );
            }
          } catch (_) {}
        }
      }
    }

    return FeatureMetadata(
      datasources: datasources,
      repositories: repositories,
      useCases: useCases,
      logics: logics,
    );
  }

  // ================= 2. Inject Feature DI =================

  Future<void> _injectFeatureDi(
    RegFeatureParam param,
    FeatureMetadata metadata,
  ) async {
    final path = param.appModuleDiPath;
    String content = await _fileService.readAsString(path);

    final diMethodName = '_${param.featureCamel}Di';
    final hasCallInRegister = content.contains('$diMethodName();');

    if (hasCallInRegister && !param.force) {
      _reportService.addSkipped(path);
      return;
    }

    final unit = parseString(content: content).unit;
    int? registerBodyOffset;
    int? classEndOffset;

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration &&
          declaration.namePart.typeName.lexeme == '${param.modulePascal}Di') {
        final body = declaration.body;
        if (body is BlockClassBody) {
          classEndOffset = body.rightBracket.offset;
          for (final member in body.members) {
            if (member is MethodDeclaration) {
              if (member.name.lexeme == 'register' &&
                  member.body is BlockFunctionBody) {
                registerBodyOffset = (member.body as BlockFunctionBody)
                    .block
                    .rightBracket
                    .offset;
              }
            }
          }
        }
      }
    }

    // 1. Inject pemanggilan di dalam register() jika belum ada
    if (!hasCallInRegister && registerBodyOffset != null) {
      final callCode = '\n    $diMethodName();\n  ';
      content =
          '${content.substring(0, registerBodyOffset)}$callCode${content.substring(registerBodyOffset)}';
    }

    // 2. Replace method _<feature>Di() jika sudah ada dan force == true, atau append jika belum ada
    final updatedUnit = parseString(content: content).unit;
    int? targetStart;
    int? targetEnd;
    int? recomputedClassEnd;

    for (final declaration in updatedUnit.declarations) {
      if (declaration is ClassDeclaration &&
          declaration.namePart.typeName.lexeme == '${param.modulePascal}Di') {
        final body = declaration.body;
        if (body is BlockClassBody) {
          recomputedClassEnd = body.rightBracket.offset;
          for (final member in body.members) {
            if (member is MethodDeclaration &&
                member.name.lexeme == diMethodName) {
              targetStart = member.offset;
              targetEnd = member.end;
            }
          }
        }
      }
    }

    final newMethodCode = ModuleDiTemplate.buildFeatureDiMethod(
      param: param,
      metadata: metadata,
    );

    if (param.force && targetStart != null && targetEnd != null) {
      content =
          '${content.substring(0, targetStart)}$newMethodCode${content.substring(targetEnd)}';
    } else if (targetStart == null) {
      final appendOffset = recomputedClassEnd ?? classEndOffset;
      if (appendOffset != null) {
        content =
            '${content.substring(0, appendOffset)}\n$newMethodCode\n${content.substring(appendOffset)}';
      }
    }

    await _fileService.writeAsString(path: path, content: content);
    _reportService.addInjected(path);
  }

  // ================= 3. Inject Feature Route =================

  Future<void> _injectFeatureRoute(RegFeatureParam param) async {
    final path = param.appModuleRoutePath;
    String content = await _fileService.readAsString(path);

    final featureBaseGetter = '${param.featureCamel}Base';
    if (content.contains(featureBaseGetter)) {
      _reportService.addSkipped(path);
      return;
    }

    final unit = parseString(content: content).unit;
    int? classBodyOffset;
    int? insertPosition;

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration &&
          declaration.namePart.typeName.lexeme ==
              '${param.modulePascal}Route') {
        final body = declaration.body;
        if (body is BlockClassBody) {
          classBodyOffset = body.leftBracket.end;

          // Cari posisi getter terakhir di dalam class route agar featureBase ditaruh di bawahnya
          final visitor = LastGetterVisitor();
          body.visitChildren(visitor);
          insertPosition = visitor.insertOffset ?? body.rightBracket.offset - 1;
        }
      }
    }

    // A. Tambahkan konstanta path di bagian atas body class Route
    if (classBodyOffset != null) {
      final constantsCode = ModuleRouteTemplate.buildConstants(param);
      content =
          '${content.substring(0, classBodyOffset)}\n$constantsCode${content.substring(classBodyOffset)}';
    }

    // Re-parse setelah penambahan konstanta untuk mendapatkan posisi insert yang akurat
    final updatedUnit = parseString(content: content).unit;
    int? recomputedInsertPos;
    for (final declaration in updatedUnit.declarations) {
      if (declaration is ClassDeclaration &&
          declaration.namePart.typeName.lexeme ==
              '${param.modulePascal}Route') {
        final body = declaration.body;
        if (body is BlockClassBody) {
          final visitor = LastGetterVisitor();
          body.visitChildren(visitor);
          recomputedInsertPos =
              visitor.insertOffset ?? body.rightBracket.offset - 1;
        }
      }
    }

    // B. Tambahkan getter RouteBase khusus feature tepat di bawah urutan getter/method yang ada
    final finalInsertPos = recomputedInsertPos ?? insertPosition;
    if (finalInsertPos != null) {
      final featureBaseRouteCode =
          '\n\n${ModuleRouteTemplate.buildFeatureBaseRoute(param)}';

      content =
          '${content.substring(0, finalInsertPos)}$featureBaseRouteCode${content.substring(finalInsertPos)}';
      await _fileService.writeAsString(path: path, content: content);
      _reportService.addInjected(path);
    }
  }
}
