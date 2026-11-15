import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/remote_ds_body_stream_template.dart';
import 'package:test/test.dart';

void main() {
  group('RemoteDsBodyStreamTemplate', () {
    group('Return + Param stream combinations', () {
      test(
        'Given sequence with isReturnParam true and isList true, '
        'When build is called, '
        'Then it generates stream body with path containing request.id and List DTO mapping',
        () {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.get,
            usecase: 'watch_user_list_use_case',
            usecasePath: '',
            method: 'watch_user_list',
            flow: FlowType.stream,
            dsMode: DsMode.remote,
            isList: true,
            entity: 'user_entity',
            dto: 'user_dto',
            param: 'user_param',
            request: 'user_request',
            featureName: 'user',
            featurePath: '',
            moduleName: 'auth',
            modulePath: '',
          );

          // Act (When)
          final result = RemoteDsBodyStreamTemplate.build(sequence);

          // Assert (Then)
          expect(
            result,
            contains(r"final path = '$_basePath/${request.id}/stream';"),
          );
          expect(result, contains('_apiClient.stream<List>(path)'));
          expect(
            result,
            contains('UserDto.fromJson(e as Map<String, dynamic>)'),
          );
          expect(result, contains('AuthException.userNotFound('));
          expect(result, contains('AuthException.fromException('));
        },
      );

      test(
        'Given sequence with isReturnParam true and isList false, '
        'When build is called, '
        'Then it generates stream body with path containing request.id and single Map DTO mapping',
        () {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.get,
            usecase: 'watch_user_detail_use_case',
            usecasePath: '',
            method: 'watch_user_detail',
            flow: FlowType.stream,
            dsMode: DsMode.remote,
            isList: false,
            entity: 'user_entity',
            dto: 'user_dto',
            param: 'user_param',
            request: 'user_request',
            featureName: 'user',
            featurePath: '',
            moduleName: 'auth',
            modulePath: '',
          );

          // Act (When)
          final result = RemoteDsBodyStreamTemplate.build(sequence);

          // Assert (Then)
          expect(
            result,
            contains(r"final path = '$_basePath/${request.id}/stream';"),
          );
          expect(
            result,
            contains('_apiClient.stream<Map<String, dynamic>>(path)'),
          );
          expect(result, contains('UserDto.fromJson(data)'));
        },
      );
    });

    group('Return only stream combinations', () {
      test(
        'Given sequence with isReturn true and isList true, '
        'When build is called, '
        'Then it generates stream body with standard path and List DTO mapping',
        () {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.get,
            usecase: 'watch_items_use_case',
            usecasePath: '',
            method: 'watch_items',
            flow: FlowType.stream,
            dsMode: DsMode.remote,
            isList: true,
            entity: 'item_entity',
            dto: 'item_dto',
            featureName: 'item',
            featurePath: '',
            moduleName: 'catalog',
            modulePath: '',
          );

          // Act (When)
          final result = RemoteDsBodyStreamTemplate.build(sequence);

          // Assert (Then)
          expect(result, contains("final path = '\$_basePath/stream';"));
          expect(result, contains('_apiClient.stream<List>(path)'));
          expect(
            result,
            contains('ItemDto.fromJson(e as Map<String, dynamic>)'),
          );
          expect(result, contains('CatalogException.itemNotFound('));
        },
      );

      test(
        'Given sequence with isReturn true and isList false, '
        'When build is called, '
        'Then it generates stream body with standard path and single Map DTO mapping',
        () {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.get,
            usecase: 'watch_item_detail_use_case',
            usecasePath: '',
            method: 'watch_item_detail',
            flow: FlowType.stream,
            dsMode: DsMode.remote,
            isList: false,
            entity: 'item_entity',
            dto: 'item_dto',
            featureName: 'item',
            featurePath: '',
            moduleName: 'catalog',
            modulePath: '',
          );

          // Act (When)
          final result = RemoteDsBodyStreamTemplate.build(sequence);

          // Assert (Then)
          expect(result, contains("final path = '\$_basePath/stream';"));
          expect(
            result,
            contains('_apiClient.stream<Map<String, dynamic>>(path)'),
          );
          expect(result, contains('ItemDto.fromJson(data)'));
        },
      );
    });

    group('Unsupported combination', () {
      test(
        'Given sequence with unsupported combination for stream (e.g. Param only or Void), '
        'When build is called, '
        'Then it throws an Exception',
        () {
          // Arrange (Given) - Hanya menggunakan param tanpa return model (masuk kategori isParam / isVoid)
          const sequence = SequenceParam(
            action: Action.get,
            usecase: 'invalid_stream_use_case',
            usecasePath: '',
            method: 'invalid_stream',
            flow: FlowType.stream,
            dsMode: DsMode.remote,
            param: 'some_param',
            request: 'some_request',
            featureName: 'user',
            featurePath: '',
            moduleName: 'auth',
            modulePath: '',
          );

          // Act & Assert (When & Then)
          expect(
            () => RemoteDsBodyStreamTemplate.build(sequence),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Model combination not support for stream flow'),
              ),
            ),
          );
        },
      );
    });
  });
}
