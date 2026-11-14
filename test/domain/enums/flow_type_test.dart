import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:test/test.dart';

void main() {
  group('FlowType Tests', () {
    test('fromValue should return correct FlowType for valid string', () {
      expect(FlowType.fromValue('sync'), FlowType.synchronous);
      expect(FlowType.fromValue('async'), FlowType.asynchronous);
      expect(FlowType.fromValue('stream'), FlowType.stream);
    });

    test('fromValue should return null for invalid string', () {
      expect(FlowType.fromValue('unknown'), isNull);
    });
  });
}
