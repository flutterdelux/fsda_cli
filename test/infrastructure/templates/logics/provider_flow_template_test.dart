import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/provider_flow_template.dart';
import 'package:test/test.dart';

void main() {
  group('ProviderFlowTemplate', () {
    test(
      'Given logic param with retrieval type, custom slice, and Provider control, '
      'When build is called, '
      'Then it generates ChangeNotifier content with ChangeNotifier base, notifyListeners, and state handling',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.retrieval,
          control: StateControl.provider,
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
        final artifact = ProviderFlowTemplate.build(logicParam);

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
          contains('class DestinationPopularProvider extends ChangeNotifier'),
        );
        expect(
          artifact.content,
          contains('Future<void> fetchPopularDestinations() async'),
        );
        expect(artifact.content, contains('notifyListeners();'));
      },
    );

    test(
      'Given logic param with stream usecase type and Provider control, '
      'When build is called, '
      'Then it generates ChangeNotifier controller content using stream subscription and dispose method',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.retrieval,
          control: StateControl.provider,
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
        final artifact = ProviderFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserDetailProvider'));
        expect(artifact.needToExport, isTrue);
        expect(
          artifact.content,
          contains('class UserDetailProvider extends ChangeNotifier'),
        );
        expect(
          artifact.content,
          contains('StreamSubscription<Result<UserEntity>>? _subscription;'),
        );
        expect(
          artifact.content,
          contains('_subscription = _watchUser(_param).listen('),
        );
        expect(artifact.content, contains('@override\n  void dispose()'));
      },
    );

    test(
      'Given logic param with mutation type and Provider control, '
      'When build is called, '
      'Then it generates mutation ChangeNotifier controller content with loading state and notifyListeners',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.mutation,
          control: StateControl.provider,
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
        final artifact = ProviderFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserCreateProvider'));
        expect(
          artifact.content,
          contains('Future<void> call(CreateUserParam param) async'),
        );
        expect(
          artifact.content,
          contains('_state = const UserCreateState.loading();'),
        );
        expect(artifact.content, contains('notifyListeners();'));
      },
    );

    test(
      'Given logic param with pagination type and Provider control, '
      'When build is called, '
      'Then it generates pagination ChangeNotifier controller content with init, refresh, and loadMore methods',
      () {
        // Arrange (Given)
        const logicParam = LogicFlowParam(
          type: LogicFlowType.pagination,
          control: StateControl.provider,
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
        final artifact = ProviderFlowTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserListProvider'));
        expect(artifact.content, contains('Future<void> init() async'));
        expect(artifact.content, contains('Future<void> refresh() async'));
        expect(artifact.content, contains('Future<void> loadMore() async'));
        expect(artifact.content, contains('notifyListeners();'));
      },
    );
  });
}
