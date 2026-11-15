import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/local_ds_body_template.dart';
import 'package:test/test.dart';

void main() {
  group('LocalDsBodyTemplate', () {
    test(
      'Given sequence with stream flow, '
      'When build is called, '
      'Then it throws an Exception because streams are not supported for local data sources',
      () async {
        // Arrange (Given)
        const sequence = SequenceParam(
          action: Action.get,
          usecase: 'watch_user_use_case',
          usecasePath: '',
          method: 'watch_user',
          flow: FlowType.stream,
          dsMode: DsMode.local,
          featureName: 'user',
          featurePath: '',
          moduleName: 'app',
          modulePath: '',
        );

        // Act & Assert (When & Then)
        expect(
          () => LocalDsBodyTemplate.build(sequence),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Stream not supported yet for local data source.'),
            ),
          ),
        );
      },
    );

    test(
      'Given sequence with isReturn true (asynchronous, single DTO), '
      'When build is called, '
      'Then it generates asynchronous local get body with JSON map conversion',
      () async {
        // Arrange (Given)
        const sequence = SequenceParam(
          action: Action.get,
          usecase: 'get_user_use_case',
          usecasePath: '',
          method: 'get_user',
          flow: FlowType.asynchronous,
          dsMode: DsMode.local,
          entity: 'user_entity',
          dto: 'user_dto',
          response: 'user_response',
          featureName: 'user',
          featurePath: '',
          moduleName: 'app',
          modulePath: '',
        );

        // Act (When)
        final result = LocalDsBodyTemplate.build(sequence);

        // Assert (Then)
        expect(result, contains('_localStorage'));
        expect(
          result,
          contains('if (jsonString == null || jsonString is! String)'),
        );
        expect(result, contains('final jsonMap = jsonDecode(jsonString);'));
        expect(
          result,
          contains('return UserDto.fromJson(jsonMap as Map<String, dynamic>);'),
        );
      },
    );

    test(
      'Given sequence with isReturn true (synchronous, isList true), '
      'When build is called, '
      'Then it generates synchronous local get body with JSON list conversion',
      () async {
        // Arrange (Given)
        const sequence = SequenceParam(
          action: Action.get,
          usecase: 'get_users_use_case',
          usecasePath: '',
          method: 'get_users',
          flow: FlowType.synchronous,
          dsMode: DsMode.local,
          isList: true,
          entity: 'user_entity', // <-- Pasangan wajib untuk pola Return
          dto: 'user_dto',
          response: 'user_response',
          featureName: 'user',
          featurePath: '',
          moduleName: 'app',
          modulePath: '',
        );

        // Act (When)
        final result = LocalDsBodyTemplate.build(sequence);

        // Assert (Then)
        expect(result, contains('_localStorage'));
        expect(result, isNot(contains('await')));
        expect(result, contains('final jsonList = jsonDecode(jsonString);'));
        expect(
          result,
          contains(
            'return jsonList.map((e) => UserDto.fromJson(e as Map<String, dynamic>)).toList();',
          ),
        );
      },
    );

    test(
      'Given sequence with isParam true (asynchronous), '
      'When build is called, '
      'Then it generates asynchronous local save body using jsonEncode on request',
      () async {
        // Arrange (Given)
        const sequence = SequenceParam(
          action: Action.post,
          usecase: 'save_user_use_case',
          usecasePath: '',
          method: 'save_user',
          flow: FlowType.asynchronous,
          dsMode: DsMode.local,
          param: 'user_param', // <-- Pasangan wajib untuk pola Param
          request: 'user_request',
          featureName: 'user',
          featurePath: '',
          moduleName: 'app',
          modulePath: '',
        );

        // Act (When)
        final result = LocalDsBodyTemplate.build(sequence);

        // Assert (Then)
        expect(
          result,
          contains('final jsonString = jsonEncode(request.toJson());'),
        );
        expect(result, contains('await _localStorage'));
      },
    );

    test(
      'Given sequence with isParam true (synchronous), '
      'When build is called, '
      'Then it generates synchronous local save body without await keyword',
      () async {
        // Arrange (Given)
        const sequence = SequenceParam(
          action: Action.post,
          usecase: 'save_user_use_case',
          usecasePath: '',
          method: 'save_user',
          flow: FlowType.synchronous,
          dsMode: DsMode.local,
          param: 'user_param', // <-- Pasangan wajib untuk pola Param
          request: 'user_request',
          featureName: 'user',
          featurePath: '',
          moduleName: 'app',
          modulePath: '',
        );

        // Act (When)
        final result = LocalDsBodyTemplate.build(sequence);

        // Assert (Then)
        expect(
          result,
          contains('final jsonString = jsonEncode(request.toJson());'),
        );
        expect(result, isNot(contains('await')));
        expect(result, contains('_localStorage'));
      },
    );

    test('Given sequence with isVoid true (asynchronous), '
        'When build is called, '
        'Then it generates asynchronous local delete/clear body', () async {
      // Arrange (Given)
      const sequence = SequenceParam(
        action: Action.delete,
        usecase: 'clear_user_use_case',
        usecasePath: '',
        method: 'clear_user',
        flow: FlowType.asynchronous,
        dsMode: DsMode.local,
        featureName: 'user',
        featurePath: '',
        moduleName: 'app',
        modulePath: '',
      );

      // Act (When)
      final result = LocalDsBodyTemplate.build(sequence);

      // Assert (Then)
      expect(result, contains('await _localStorage'));
    });

    test(
      'Given sequence with isVoid true (synchronous), '
      'When build is called, '
      'Then it generates synchronous local delete/clear body without await',
      () async {
        // Arrange (Given)
        const sequence = SequenceParam(
          action: Action.delete,
          usecase: 'clear_user_use_case',
          usecasePath: '',
          method: 'clear_user',
          flow: FlowType.synchronous,
          dsMode: DsMode.local,
          featureName: 'user',
          featurePath: '',
          moduleName: 'app',
          modulePath: '',
        );

        // Act (When)
        final result = LocalDsBodyTemplate.build(sequence);

        // Assert (Then)
        expect(result, isNot(contains('await')));
        expect(result, contains('_localStorage'));
      },
    );
  });
}
