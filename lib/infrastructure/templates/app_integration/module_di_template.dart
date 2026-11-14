import '../../../core/extensions/app_integration_param_x.dart';
import '../../../domain/models/dependency_metadata.dart';
import '../../../domain/models/feature_metadata.dart';
import '../../../domain/params/app_integration/reg_feature_param.dart';

abstract final class ModuleDiTemplate {
  /// Membentuk kode method `static void _<feature>Di()`
  static String buildFeatureDiMethod({
    required RegFeatureParam param,
    required FeatureMetadata metadata,
  }) {
    final diMethodName = '_${param.featureCamel}Di';

    final datasourcesBlock = _buildDatasources(param, metadata.datasources);
    final repositoriesBlock = _buildRepositories(param, metadata.repositories);
    final useCasesBlock = _buildUseCases(param, metadata.useCases);
    final logicsBlock = _buildLogics(param, metadata.logics);

    return '''
  static void $diMethodName() {
$datasourcesBlock

$repositoriesBlock

$useCasesBlock

$logicsBlock
  }
''';
  }

  static String _buildDatasources(
    RegFeatureParam param,
    List<DependencyMetadata> datasources,
  ) {
    if (datasources.isEmpty) return '    // Datasources';

    final buffer = StringBuffer('    // Datasources\n');
    for (final ds in datasources) {
      final interfaceName = ds.className.replaceAll('Impl', '');

      final argsBuilder = <String>[];
      for (final pMeta in ds.parameters) {
        if (pMeta.type == 'ApiClient') {
          argsBuilder.add('${pMeta.name}: sl()');
        } else {
          argsBuilder.add(pMeta.isNamed ? '${pMeta.name}: sl()' : 'sl()');
        }
      }

      buffer.writeln(
        '    sl.registerLazySingleton<$interfaceName>(\n'
        '      () => ${ds.className}(\n'
        '        ${argsBuilder.join(',\n        ')},\n'
        '      ),\n'
        '    );',
      );
    }
    return buffer.toString().trimRight();
  }

  static String _buildRepositories(
    RegFeatureParam param,
    List<DependencyMetadata> repositories,
  ) {
    if (repositories.isEmpty) return '    // Repositories';

    final buffer = StringBuffer('    // Repositories\n');
    for (final repo in repositories) {
      final interfaceName = repo.className.replaceAll('Impl', '');

      final argsBuilder = <String>[];
      for (final pMeta in repo.parameters) {
        if (pMeta.type == 'AppLogger') {
          argsBuilder.add("${pMeta.name}: sl(param1: '$interfaceName')");
        } else {
          argsBuilder.add(pMeta.isNamed ? '${pMeta.name}: sl()' : 'sl()');
        }
      }

      buffer.writeln(
        '    sl.registerLazySingleton<$interfaceName>(\n'
        '      () => ${repo.className}(\n'
        '        ${argsBuilder.join(',\n        ')},\n'
        '      ),\n'
        '    );',
      );
    }
    return buffer.toString().trimRight();
  }

  static String _buildUseCases(
    RegFeatureParam param,
    List<DependencyMetadata> useCases,
  ) {
    if (useCases.isEmpty) return '    // Usecases';

    final buffer = StringBuffer('    // Usecases\n');
    for (final uc in useCases) {
      final argsBuilder = <String>[];
      for (final pMeta in uc.parameters) {
        argsBuilder.add(pMeta.isNamed ? '${pMeta.name}: sl()' : 'sl()');
      }

      buffer.writeln(
        '    sl.registerLazySingleton(\n'
        '      () => ${uc.className}(\n'
        '        ${argsBuilder.join(',\n        ')},\n'
        '      ),\n'
        '    );',
      );
    }
    return buffer.toString().trimRight();
  }

  static String _buildLogics(
    RegFeatureParam param,
    List<DependencyMetadata> logics,
  ) {
    if (logics.isEmpty) return '    // Logic';

    final buffer = StringBuffer('    // Logic\n');
    for (final logic in logics) {
      final hasExternalParam = logic.parameters.any(
        (p) => p.type.endsWith('Param') || p.type.endsWith('Entity'),
      );

      final argsBuilder = <String>[];
      for (final pMeta in logic.parameters) {
        if (pMeta.type.endsWith('Param') || pMeta.type.endsWith('Entity')) {
          argsBuilder.add(pMeta.isNamed ? '${pMeta.name}: param' : 'param');
        } else {
          argsBuilder.add(pMeta.isNamed ? '${pMeta.name}: sl()' : 'sl()');
        }
      }

      if (hasExternalParam) {
        final extParam = logic.parameters.firstWhere(
          (p) => p.type.endsWith('Param') || p.type.endsWith('Entity'),
        );
        buffer.writeln(
          '    sl.registerFactoryParam<${logic.className}, ${extParam.type}, void>(\n'
          '      (param, _) => ${logic.className}(\n'
          '        ${argsBuilder.join(',\n        ')},\n'
          '      ),\n'
          '    );',
        );
      } else {
        buffer.writeln(
          '    sl.registerFactory(\n'
          '      () => ${logic.className}(\n'
          '        ${argsBuilder.join(',\n        ')}\n'
          '      ),\n'
          '    );',
        );
      }
    }
    return buffer.toString().trimRight();
  }
}
