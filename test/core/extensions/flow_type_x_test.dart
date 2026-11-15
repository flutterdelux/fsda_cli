import 'package:fsda_cli/core/extensions/flow_type_x.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:test/test.dart';

void main() {
  group('FlowTypeX Extension', () {
    test('Given FlowType is asynchronous, '
        'When returnType and resultType are accessed, '
        'Then it returns "Future" and "AsyncResult" respectively', () {
      // Arrange (Given)
      const flowType = FlowType.asynchronous;

      // Act & Assert (When & Then)
      expect(flowType.returnType, equals('Future'));
      expect(flowType.resultType, equals('AsyncResult'));
    });

    test('Given FlowType is synchronous, '
        'When returnType and resultType are accessed, '
        'Then returnType returns null and resultType returns "Result"', () {
      // Arrange (Given)
      const flowType = FlowType.synchronous;

      // Act & Assert (When & Then)
      expect(flowType.returnType, isNull);
      expect(flowType.resultType, equals('Result'));
    });

    test('Given FlowType is stream, '
        'When returnType and resultType are accessed, '
        'Then it returns "Stream" and "StreamResult" respectively', () {
      // Arrange (Given)
      const flowType = FlowType.stream;

      // Act & Assert (When & Then)
      expect(flowType.returnType, equals('Stream'));
      expect(flowType.resultType, equals('StreamResult'));
    });
  });
}
