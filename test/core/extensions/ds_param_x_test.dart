import 'package:fsda_cli/core/extensions/ds_param_x.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/params/ds_param.dart';
import 'package:test/test.dart';

void main() {
  group('DsParamX Tests', () {
    test('should generate correct paths for local and remote data sources', () {
      final localParam = const DsParam(
        moduleName: 'auth',
        modulePath: '/modules/auth',
        featureName: 'login',
        featurePath: '/modules/auth/lib/src/features/login',
        mode: DsMode.local,
      );

      expect(
        localParam.featureBarrelPath,
        '/modules/auth/lib/src/features/login/login_feature.dart',
      );
      expect(
        localParam.interfacePath,
        '/modules/auth/lib/src/features/login/data/datasources/login_local_data_source.dart',
      );
      expect(
        localParam.implPath,
        '/modules/auth/lib/src/features/login/data/datasources/login_local_data_source_impl.dart',
      );

      final remoteParam = const DsParam(
        moduleName: 'auth',
        modulePath: '/modules/auth',
        featureName: 'login',
        featurePath: '/modules/auth/lib/src/features/login',
        mode: DsMode.remote,
      );

      expect(
        remoteParam.interfacePath,
        '/modules/auth/lib/src/features/login/data/datasources/login_remote_data_source.dart',
      );
      expect(
        remoteParam.implPath,
        '/modules/auth/lib/src/features/login/data/datasources/login_remote_data_source_impl.dart',
      );
    });
  });
}
