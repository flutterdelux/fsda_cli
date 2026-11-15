import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/getx_flow_template.dart';
import 'package:test/test.dart';

void main() {
  group('GetxFlowTemplate', () {
    test(
      'Given logic param with retrieval type, custom slice, and destination feature, '
      'When build is called, '
      'Then it generates controller following <feature><slice><suffix> pattern with correct usecase name and repo method',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.retrieval,
          control: StateControl.getx,
          uc: LogicUcModel(
            name: 'destination_popular_use_case',
            path:
                'modules/location/lib/src/domain/usecases/destination_popular_use_case.dart',
            type: UcType.returnUc,
            method: 'fetchPopularDestinations',
            returnType: 'List<DestinationEntity>',
          ),
          featureName: 'destination',
          featurePath: 'modules/location/lib/src/features/destination',
          moduleName: 'location',
          modulePath: 'modules/location',
          slice: 'popular',
        );

        // Act (When)
        final artifact = GetxFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('DestinationPopularController'));
        expect(artifact.needToExport, isTrue);

        expect(
          artifact.path,
          contains(
            'modules/location/lib/src/features/destination/logic/popular/destination_popular_controller.dart',
          ),
        );

        expect(
          artifact.typesToImport,
          containsAll(['DestinationPopularState', 'DestinationPopularUseCase']),
        );
        expect(
          artifact.content,
          contains('class DestinationPopularController extends GetxController'),
        );
        expect(
          artifact.content,
          contains('Future<void> fetchPopularDestinations() async'),
        );
        expect(artifact.content, contains('_destinationPopularUseCase()'));
      },
    );

    test(
      'Given logic param with stream usecase type and GetX control, '
      'When build is called, '
      'Then it generates GetX controller content using stream logic, rxState, and correct workspace path',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.retrieval,
          control: StateControl.getx,
          uc: LogicUcModel(
            name: 'watch_user',
            path: 'path/to/watch_user.dart',
            type: UcType.paramStreamUc,
            method: 'watchUser',
            returnType: 'UserEntity',
            paramType: 'UserParam',
          ),
          featureName: 'user',
          featurePath: 'modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: 'modules/auth',
          slice: 'detail',
        );

        // Act (When)
        final artifact = GetxFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserDetailController'));
        expect(artifact.needToExport, isTrue);

        // Verifikasi path workspace
        expect(artifact.path, contains('modules/auth/lib/src/features/user'));

        expect(
          artifact.typesToImport,
          containsAll(['UserDetailState', 'WatchUser', 'UserParam']),
        );
        expect(
          artifact.content,
          contains('class UserDetailController extends GetxController'),
        );
        expect(
          artifact.content,
          contains('late final Rx<UserDetailState> rxState;'),
        );
        expect(
          artifact.content,
          contains('StreamSubscription<Result<UserEntity>>? _subscription;'),
        );
        expect(
          artifact.content,
          contains('_subscription = _watchUser(_param).listen('),
        );
        expect(artifact.content, contains('void onClose()'));
      },
    );

    test(
      'Given logic param with mutation type, parameters, and GetX control, '
      'When build is called, '
      'Then it generates mutation GetX controller content with rxState mutation handling',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.mutation,
          control: StateControl.getx,
          uc: LogicUcModel(
            name: 'create_user',
            path: 'path/to/create_user.dart',
            type: UcType.returnParamUc,
            method: 'call',
            returnType: 'UserEntity',
            paramType: 'CreateUserParam',
          ),
          featureName: 'user',
          featurePath: 'modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: 'modules/auth',
          slice: 'create',
        );

        // Act (When)
        final artifact = GetxFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserCreateController'));
        expect(
          artifact.typesToImport,
          containsAll(['UserCreateState', 'CreateUser', 'CreateUserParam']),
        );
        expect(
          artifact.content,
          contains('Future<void> call(CreateUserParam param) async'),
        );
        expect(
          artifact.content,
          contains('rxState.value = const UserCreateState.loading();'),
        );
        expect(
          artifact.content,
          contains('success: (data) => UserCreateState.success(data: data)'),
        );
      },
    );

    test(
      'Given logic param with pagination type and GetX control, '
      'When build is called, '
      'Then it generates pagination GetX controller content with init, refresh, and loadMore methods',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.pagination,
          control: StateControl.getx,
          uc: LogicUcModel(
            name: 'get_users',
            path: 'path/to/get_users.dart',
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
        final artifact = GetxFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserListController'));
        expect(
          artifact.typesToImport,
          containsAll(['UserListState', 'GetUsers', 'PaginationParam']),
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
