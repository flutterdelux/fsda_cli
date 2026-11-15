import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/cubit_flow_template.dart';
import 'package:test/test.dart';

void main() {
  group('CubitFlowTemplate', () {
    test(
      'Given logic param with stream usecase type, '
      'When build is called, '
      'Then it generates cubit content using stream logic and correct imports',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.retrieval,
          uc: LogicUcModel(
            name: 'watch_user',
            path: 'path/to/watch_user.dart',
            type: UcType.paramStreamUc,
            method: 'watchUser',
            returnType: 'UserEntity',
            paramType: 'UserParam',
          ),
          featureName: 'user',
          featurePath: 'features/user',
          moduleName: 'app',
          modulePath: 'modules/app',
          slice: 'detail',
        );

        // Act (When)
        final artifact = CubitFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserDetailCubit'));
        expect(artifact.needToExport, isTrue);
        expect(
          artifact.typesToImport,
          containsAll([
            'UserDetailState',
            'WatchUser',
            'UserParam',
          ]), // Disesuaikan
        );
        expect(
          artifact.content,
          contains('class UserDetailCubit extends Cubit<UserDetailState>'),
        );
        expect(
          artifact.content,
          contains('StreamSubscription<Result<UserEntity>>? _subscription;'),
        );
        expect(artifact.content, contains('_watchUser(_param).listen('));
      },
    );

    test(
      'Given logic param with mutation type and parameters, '
      'When build is called, '
      'Then it generates mutation cubit content with success and failure handling',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.mutation,
          uc: LogicUcModel(
            name: 'create_user',
            path: 'path/to/create_user.dart',
            type: UcType.returnParamUc,
            method: 'call',
            returnType: 'UserEntity',
            paramType: 'CreateUserParam',
          ),
          featureName: 'user',
          featurePath: 'features/user',
          moduleName: 'app',
          modulePath: 'modules/app',
          slice: 'create',
        );

        // Act (When)
        final artifact = CubitFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserCreateCubit'));
        expect(
          artifact.typesToImport,
          containsAll([
            'UserCreateState',
            'CreateUser',
            'CreateUserParam',
          ]), // Disesuaikan
        );
        expect(
          artifact.content,
          contains('Future<void> call(CreateUserParam param) async'),
        );
        expect(
          artifact.content,
          contains('emit(const UserCreateState.loading());'),
        );
        expect(
          artifact.content,
          contains('success: (data) => UserCreateState.success(data: data)'),
        );
      },
    );

    test('Given logic param with retrieval type and parameters, '
        'When build is called, '
        'Then it generates retrieval cubit content storing param in field', () {
      // Arrange (Given)
      const logicParam = LogicFlowParam(
        type: LogicFlowType.retrieval,
        uc: LogicUcModel(
          name: 'get_user_detail',
          path: 'path/to/get_user_detail.dart',
          type: UcType.returnParamUc,
          method: 'call',
          returnType: 'UserEntity',
          paramType: 'UserDetailParam',
        ),
        featureName: 'user',
        featurePath: 'features/user',
        moduleName: 'app',
        modulePath: 'modules/app',
        slice: 'detail',
      );

      // Act (When)
      final artifact = CubitFlowTemplate.build(logicParam);

      // Assert (Then)
      expect(artifact.name, equals('UserDetailCubit'));
      expect(
        artifact.typesToImport,
        containsAll([
          'UserDetailState',
          'GetUserDetail',
          'UserDetailParam',
        ]), // Disesuaikan
      );
      expect(artifact.content, contains('final UserDetailParam _param;'));
      expect(artifact.content, contains('Future<void> call() async'));
      expect(
        artifact.content,
        contains('success: (data) => UserDetailState.loaded(data: data)'),
      );
    });

    test(
      'Given logic param with pagination type, '
      'When build is called, '
      'Then it generates pagination cubit content with init, refresh, and loadMore methods',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.pagination,
          uc: LogicUcModel(
            name: 'get_users',
            path: 'path/to/get_users.dart',
            type: UcType.returnParamUc,
            method: 'call',
            returnType: 'List<UserEntity>',
            paramType: 'PaginationParam',
          ),
          featureName: 'user',
          featurePath: 'features/user',
          moduleName: 'app',
          modulePath: 'modules/app',
          slice: 'list',
        );

        // Act (When)
        final artifact = CubitFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserListCubit'));
        expect(
          artifact.typesToImport,
          containsAll([
            'UserListState',
            'GetUsers',
            'PaginationParam',
          ]), // Disesuaikan
        );
        expect(artifact.content, contains('Future<void> init() async'));
        expect(artifact.content, contains('Future<void> refresh() async'));
        expect(artifact.content, contains('Future<void> loadMore() async'));
        expect(
          artifact.content,
          contains('Future<void> _getData({required int page}) async'),
        );
      },
    );
  });
}
