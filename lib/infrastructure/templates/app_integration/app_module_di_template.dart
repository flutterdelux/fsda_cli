import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/reg_module_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/params/app_integration/reg_module_param.dart';

abstract final class AppModuleDiTemplate {
  static ArtifactGenerationModel build(RegModuleParam param) {
    final content =
        '''
import 'package:${param.moduleSnake}/${param.moduleSnake}.dart';

import '../../core/di/di.dart';

abstract final class ${param.modulePascal}Di {
  static void register() {
    // reg feature di
  }
}
''';

    return ArtifactGenerationModel(
      name: '${param.modulePascal}Di',
      path: param.appModuleDiPath,
      content: content,
      typesToImport: {},
      needToExport: false,
    );
  }
}
