import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/remote_ds_body_template.dart';
import 'package:test/test.dart';

void main() {
  group('RemoteDsBodyTemplate', () {
    test('Given sequence with asynchronous flow, '
        'When build is called, '
        'Then it delegates generation to RemoteDsBodyAsyncTemplate', () {
      // Arrange (Given)
      const sequence = SequenceParam(
        action: Action.post,
        usecase: 'logout_use_case',
        usecasePath: '',
        method: 'logout',
        flow: FlowType.asynchronous,
        dsMode: DsMode.remote,
        featureName: 'session',
        featurePath: '',
        moduleName: 'auth',
        modulePath: '',
      );

      // Act (When)
      final result = RemoteDsBodyTemplate.build(sequence);

      // Assert (Then)
      expect(result, contains('final path = _basePath;'));
      expect(result, contains('_apiClient.post<Map<String, dynamic>>(path);'));
    });

    test('Given sequence with stream flow, '
        'When build is called, '
        'Then it delegates generation to RemoteDsBodyStreamTemplate', () {
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
      final result = RemoteDsBodyTemplate.build(sequence);

      // Assert (Then)
      expect(result, contains("final path = '\$_basePath/stream';"));
      expect(result, contains('_apiClient.stream<List>(path)'));
    });

    test(
      'Given sequence with synchronous flow, '
      'When build is called, '
      'Then it throws an Exception because synchronous flow with remote source is not available',
      () {
        // Arrange (Given)
        const sequence = SequenceParam(
          action: Action.get,
          usecase: 'get_sync_use_case',
          usecasePath: '',
          method: 'get_sync',
          flow: FlowType.synchronous,
          dsMode: DsMode.remote,
          featureName: 'user',
          featurePath: '',
          moduleName: 'auth',
          modulePath: '',
        );

        // Act & Assert (When & Then)
        expect(
          () => RemoteDsBodyTemplate.build(sequence),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains(
                'Synchronous flow with source remote are not available.',
              ),
            ),
          ),
        );
      },
    );
  });
}
