import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/state_flow_template.dart';
import 'package:test/test.dart';

void main() {
  group('StateFlowTemplate', () {
    test(
      'Given logic param with retrieval type, '
      'When build is called, '
      'Then it generates sealed Freezed state content with initial, loading, loaded, and failure constructors',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.retrieval,
          uc: LogicUcModel(
            name: 'user_detail_use_case',
            path:
                'modules/auth/lib/src/domain/usecases/user_detail_use_case.dart',
            type: UcType.returnUc,
            method: 'call',
            returnType: 'UserEntity',
          ),
          featureName: 'user',
          featurePath: 'modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: 'modules/auth',
          slice: 'detail',
        );

        // Act (When)
        final artifact = StateFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserDetailState'));
        expect(artifact.needToExport, isTrue);
        expect(
          artifact.content,
          contains('sealed class UserDetailState with _\$UserDetailState'),
        );
        expect(
          artifact.content,
          contains('const factory UserDetailState.initial() = _Initial;'),
        );
        expect(
          artifact.content,
          contains('const factory UserDetailState.loading() = _Loading;'),
        );
        expect(
          artifact.content,
          contains(
            'const factory UserDetailState.loaded({required UserEntity data}) = _Loaded;',
          ),
        );
        expect(
          artifact.content,
          contains(
            'const factory UserDetailState.failure({required Failure failure}) = _Failure;',
          ),
        );
      },
    );

    test(
      'Given logic param with mutation type, '
      'When build is called, '
      'Then it generates sealed Freezed state content with success constructor containing data',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.mutation,
          uc: LogicUcModel(
            name: 'user_create_use_case',
            path:
                'modules/auth/lib/src/domain/usecases/user_create_use_case.dart',
            type: UcType.returnParamUc,
            method: 'call',
            returnType: 'bool',
            paramType: 'CreateUserParam',
          ),
          featureName: 'user',
          featurePath: 'modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: 'modules/auth',
          slice: 'create',
        );

        // Act (When)
        final artifact = StateFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserCreateState'));
        expect(
          artifact.content,
          contains('sealed class UserCreateState with _\$UserCreateState'),
        );
        expect(
          artifact.content,
          contains(
            'const factory UserCreateState.success({required bool data}) = _Success;',
          ),
        );
        expect(
          artifact.typesToImport,
          containsAll(['bool', 'CreateUserParam']),
        );
      },
    );

    test(
      'Given logic param with pagination type, '
      'When build is called, '
      'Then it generates pagination Freezed state content with data, hasReachedMax, isLoading, failure, and param',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.pagination,
          uc: LogicUcModel(
            name: 'user_list_use_case',
            path:
                'modules/auth/lib/src/domain/usecases/user_list_use_case.dart',
            type: UcType.returnParamUc,
            method: 'call',
            returnType: 'List<UserEntity>',
            paramType: 'PaginationParam',
          ),
          featureName: 'user',
          featurePath: 'modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: 'modules/auth',
          slice: 'list',
        );

        // Act (When)
        final artifact = StateFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserListState'));
        expect(
          artifact.content,
          contains('abstract class UserListState with _\$UserListState'),
        );
        expect(
          artifact.content,
          contains('@Default([]) List<UserEntity> data,'),
        );
        expect(
          artifact.content,
          contains('@Default(false) bool hasReachedMax,'),
        );
        expect(artifact.content, contains('@Default(false) bool isLoading,'));
        expect(artifact.content, contains('Failure? failure,'));
        expect(
          artifact.content,
          contains('@Default(PaginationParam()) PaginationParam param,'),
        );
      },
    );
  });
}
