import 'package:fsda_cli/core/extensions/ds_param_x.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/params/ds_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('DsParamX', () {
    final expectedFeaturePath = p.join(
      '/projects/my_workspace',
      'modules',
      'auth',
      'lib',
      'src',
      'features',
      'authentication',
    );

    test(
      'GIVEN a DsParam instance with DsMode.remote '
      'WHEN interfacePath and implPath getters are accessed '
      'THEN returns remote data source interface and implementation paths accurately',
      () {
        // Given
        const param = DsParam(
          mode: DsMode.remote,
          featureName: 'authentication',
          moduleName: 'auth',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );

        // When & Then
        expect(
          param.interfacePath,
          p.join(
            expectedFeaturePath,
            'data',
            'datasources',
            'authentication_remote_data_source.dart',
          ),
        );
        expect(
          param.implPath,
          p.join(
            expectedFeaturePath,
            'data',
            'datasources',
            'authentication_remote_data_source_impl.dart',
          ),
        );
      },
    );

    test(
      'GIVEN a DsParam instance with DsMode.local '
      'WHEN interfacePath and implPath getters are accessed '
      'THEN returns local data source interface and implementation paths accurately',
      () {
        // Given
        const param = DsParam(
          mode: DsMode.local,
          featureName: 'authentication',
          moduleName: 'auth',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );

        // When & Then
        expect(
          param.interfacePath,
          p.join(
            expectedFeaturePath,
            'data',
            'datasources',
            'authentication_local_data_source.dart',
          ),
        );
        expect(
          param.implPath,
          p.join(
            expectedFeaturePath,
            'data',
            'datasources',
            'authentication_local_data_source_impl.dart',
          ),
        );
      },
    );
  });
}
