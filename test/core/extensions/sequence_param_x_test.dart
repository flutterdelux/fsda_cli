import 'package:fsda_cli/core/extensions/sequence_param_x.dart';
import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    Action action = Action.get,
    String usecase = 'task_list_get_use_case',
    String method = 'get_task_list',
    FlowType flow = FlowType.asynchronous,
    DsMode dsMode = DsMode.remote,
    String? entity,
    String? param,
    String? dto,
    String? request,
    String? response,
  }) {
    return SequenceParam(
      action: action,
      usecase: usecase,
      method: method,
      flow: flow,
      dsMode: dsMode,
      entity: entity,
      param: param,
      dto: dto,
      request: request,
      response: response,
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('SequenceParamX', () {
    final expectedFeaturePath = p.join(
      '/projects/my_workspace',
      'modules',
      'project_management',
      'lib',
      'src',
      'features',
      'task',
    );

    group('Presence & Signature Getters', () {
      test(
        'GIVEN SequenceParam without models WHEN flags accessed THEN isVoid is true',
        () {
          final param = createParam();

          expect(param.hasEntity, isFalse);
          expect(param.hasDto, isFalse);
          expect(param.hasParam, isFalse);
          expect(param.hasRequest, isFalse);
          expect(param.hasResponse, isFalse);
          expect(param.hasReturnModel, isFalse);
          expect(param.hasParamModel, isFalse);
          expect(param.isVoid, isTrue);
          expect(param.isParam, isFalse);
          expect(param.isReturn, isFalse);
          expect(param.isReturnParam, isFalse);
        },
      );

      test(
        'GIVEN SequenceParam with param and request WHEN flags accessed THEN isParam is true',
        () {
          final param = createParam(
            param: 'task_delete_param',
            request: 'task_delete_request',
          );

          expect(param.hasParamModel, isTrue);
          expect(param.hasReturnModel, isFalse);
          expect(param.isParam, isTrue);
          expect(param.isVoid, isFalse);
        },
      );

      test(
        'GIVEN SequenceParam with entity and dto WHEN flags accessed THEN isReturn is true',
        () {
          final param = createParam(entity: 'task_entity', dto: 'task_dto');

          expect(param.hasReturnModel, isTrue);
          expect(param.hasParamModel, isFalse);
          expect(param.isReturn, isTrue);
          expect(param.isVoid, isFalse);
        },
      );

      test(
        'GIVEN SequenceParam with all models WHEN flags accessed THEN isReturnParam is true',
        () {
          final param = createParam(
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_create_param',
            request: 'task_create_request',
            response: 'task_response',
          );

          expect(param.hasResponse, isTrue);
          expect(param.hasReturnModel, isTrue);
          expect(param.hasParamModel, isTrue);
          expect(param.isReturnParam, isTrue);
        },
      );
    });

    group('Naming, Path, & Case-Conversion Getters', () {
      test(
        'GIVEN SequenceParam with _use_case suffix and all models WHEN getters accessed THEN returns converted names and paths',
        () {
          final param = createParam(
            usecase: 'task_create_use_case',
            method: 'create_task',
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_create_param',
            request: 'task_create_request',
            response: 'task_response',
          );

          expect(param.ucSnake, 'task_create_use_case');
          expect(param.ucCamel, 'taskCreateUseCase');
          expect(param.ucPascal, 'TaskCreateUseCase');
          expect(
            param.ucPath,
            p.join(
              expectedFeaturePath,
              'domain',
              'usecases',
              'task_create_use_case.dart',
            ),
          );

          expect(param.ucBaseSnake, 'task_create');
          expect(param.ucBaseCamel, 'taskCreate');
          expect(param.ucBasePascal, 'TaskCreate');

          expect(param.methodSnake, 'create_task');
          expect(param.methodCamel, 'createTask');
          expect(param.methodTitle, 'Create Task');

          expect(param.entitySnake, 'task_entity');
          expect(param.entityCamel, 'taskEntity');
          expect(param.entityPascal, 'TaskEntity');
          expect(
            param.entityPath,
            p.join(
              expectedFeaturePath,
              'domain',
              'entities',
              'task_entity.dart',
            ),
          );

          expect(param.dtoSnake, 'task_dto');
          expect(param.dtoCamel, 'taskDto');
          expect(param.dtoPascal, 'TaskDto');
          expect(
            param.dtoPath,
            p.join(expectedFeaturePath, 'data', 'dtos', 'task_dto.dart'),
          );

          expect(param.paramSnake, 'task_create_param');
          expect(param.paramCamel, 'taskCreateParam');
          expect(param.paramPascal, 'TaskCreateParam');
          expect(
            param.paramPath,
            p.join(
              expectedFeaturePath,
              'domain',
              'params',
              'task_create_param.dart',
            ),
          );

          expect(param.requestSnake, 'task_create_request');
          expect(param.requestCamel, 'taskCreateRequest');
          expect(param.requestPascal, 'TaskCreateRequest');
          expect(
            param.requestPath,
            p.join(
              expectedFeaturePath,
              'data',
              'requests',
              'task_create_request.dart',
            ),
          );

          expect(param.responseSnake, 'task_response');
          expect(param.responseCamel, 'taskResponse');
          expect(param.responsePascal, 'TaskResponse');
          expect(
            param.responsePath,
            p.join(
              expectedFeaturePath,
              'data',
              'responses',
              'task_response.dart',
            ),
          );
        },
      );

      test(
        'GIVEN SequenceParam without _use_case suffix and null models WHEN getters accessed THEN preserves base and returns nulls',
        () {
          final param = createParam(usecase: 'dashboard_fetch');

          expect(param.ucBaseSnake, 'dashboard_fetch');
          expect(param.ucBaseCamel, 'dashboardFetch');
          expect(param.ucBasePascal, 'DashboardFetch');
          expect(param.entityCamel, isNull);
          expect(param.dtoPascal, isNull);
          expect(param.paramSnake, isNull);
          expect(param.requestCamel, isNull);
          expect(param.responsePascal, isNull);
        },
      );
    });

    group('DataSource, HTTP, and Storage Getters', () {
      test(
        'GIVEN remote and local DsMode WHEN dsVar accessed THEN returns private field name',
        () {
          expect(createParam(dsMode: DsMode.remote).dsVar, '_remoteDataSource');
          expect(createParam(dsMode: DsMode.local).dsVar, '_localDataSource');
        },
      );

      test(
        'GIVEN every Action WHEN storage and HTTP getters accessed THEN returns expected values',
        () {
          final cases =
              <Action, ({String storage, bool body, bool query, int status})>{
                Action.post: (
                  storage: 'write',
                  body: true,
                  query: false,
                  status: 201,
                ),
                Action.get: (
                  storage: 'read',
                  body: false,
                  query: true,
                  status: 200,
                ),
                Action.put: (
                  storage: 'write',
                  body: true,
                  query: false,
                  status: 200,
                ),
                Action.patch: (
                  storage: 'write',
                  body: true,
                  query: false,
                  status: 200,
                ),
                Action.delete: (
                  storage: 'remove',
                  body: false,
                  query: false,
                  status: 204,
                ),
              };

          cases.forEach((action, expected) {
            final param = createParam(action: action);
            expect(param.localStorageMethod, expected.storage);
            expect(param.useBodyRequest, expected.body);
            expect(param.useQueryParam, expected.query);
            expect(param.httpStatus, expected.status);
          });
        },
      );

      test(
        'GIVEN Actions and FlowType.stream WHEN apiClientMethod accessed THEN returns typed method name',
        () {
          expect(
            createParam(action: Action.post).apiClientMethod,
            'post<Map<String, dynamic>>',
          );
          expect(
            createParam(action: Action.get).apiClientMethod,
            'get<Map<String, dynamic>>',
          );
          expect(
            createParam(
              action: Action.get,
              flow: FlowType.stream,
            ).apiClientMethod,
            'stream<Map<String, dynamic>>',
          );
          expect(
            createParam(action: Action.put).apiClientMethod,
            'put<Map<String, dynamic>>',
          );
          expect(
            createParam(action: Action.patch).apiClientMethod,
            'patch<Map<String, dynamic>>',
          );
          expect(createParam(action: Action.delete).apiClientMethod, 'delete');
        },
      );
    });
    group('DataSource Path Getters', () {
      test(
        'GIVEN remote and local DsMode WHEN path getters accessed THEN returns datasource file paths',
        () {
          final dsDir = p.join(expectedFeaturePath, 'data', 'datasources');
          final remote = createParam(dsMode: DsMode.remote);
          expect(
            remote.dsInterfacePath,
            p.join(dsDir, 'task_remote_data_source.dart'),
          );
          expect(
            remote.dsImplPath,
            p.join(dsDir, 'task_remote_data_source_impl.dart'),
          );
          final local = createParam(dsMode: DsMode.local);
          expect(
            local.dsInterfacePath,
            p.join(dsDir, 'task_local_data_source.dart'),
          );
          expect(
            local.dsImplPath,
            p.join(dsDir, 'task_local_data_source_impl.dart'),
          );
        },
      );
    });
  });
}
