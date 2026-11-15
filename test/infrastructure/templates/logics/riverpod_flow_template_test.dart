import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/riverpod_flow_template.dart';
import 'package:test/test.dart';

void main() {
  group('RiverpodFlowTemplate', () {
    test(
      'Given logic param with retrieval type, custom slice, and Riverpod control, '
      'When build is called, '
      'Then it generates Notifier content extending Notifier, override build, and state return',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.retrieval,
          control: StateControl.riverpod,
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
        final artifact = RiverpodFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('DestinationPopularProvider'));
        expect(artifact.needToExport, isTrue);
        expect(
          artifact.path,
          contains(
            'modules/location/lib/src/features/destination/logic/popular/destination_popular_provider.dart',
          ),
        );

        expect(
          artifact.typesToImport,
          containsAll(['DestinationPopularState', 'DestinationPopularUseCase']),
        );
        expect(
          artifact.content,
          contains(
            'class DestinationPopularProvider extends Notifier<DestinationPopularState>',
          ),
        );
        expect(
          artifact.content,
          contains('Future<void> fetchPopularDestinations() async'),
        );
        expect(
          artifact.content,
          contains('return const DestinationPopularState.initial();'),
        );
      },
    );

    test(
      'Given logic param with stream usecase type and Riverpod control, '
      'When build is called, '
      'Then it generates Notifier content using stream subscription and ref.onDispose cleanup',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.retrieval,
          control: StateControl.riverpod,
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
        final artifact = RiverpodFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserDetailProvider'));
        expect(artifact.needToExport, isTrue);
        expect(
          artifact.content,
          contains(
            'class UserDetailProvider extends Notifier<UserDetailState>',
          ),
        );
        expect(
          artifact.content,
          contains('StreamSubscription<Result<UserEntity>>? _subscription;'),
        );
        expect(artifact.content, contains('ref.onDispose('));
        expect(
          artifact.content,
          contains('_subscription = _watchUser(param).listen('),
        );
      },
    );

    test(
      'Given logic param with mutation type and Riverpod control, '
      'When build is called, '
      'Then it generates mutation Notifier content with loading state and state updates',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.mutation,
          control: StateControl.riverpod,
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
        final artifact = RiverpodFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserCreateProvider'));
        expect(
          artifact.content,
          contains('Future<void> call(CreateUserParam param) async'),
        );
        expect(
          artifact.content,
          contains('state = const UserCreateState.loading();'),
        );
      },
    );

    test(
      'Given logic param with pagination type and Riverpod control, '
      'When build is called, '
      'Then it generates pagination Notifier content with init, refresh, and loadMore methods',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.pagination,
          control: StateControl.riverpod,
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
        final artifact = RiverpodFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserListProvider'));
        expect(artifact.content, contains('Future<void> init() async'));
        expect(artifact.content, contains('Future<void> refresh() async'));
        expect(artifact.content, contains('Future<void> loadMore() async'));
      },
    );
  });
}
