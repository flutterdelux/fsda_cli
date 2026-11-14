import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:test/test.dart';

void main() {
  group('LogicFlowType Tests', () {
    test('fromvalue should return correct LogicFlowType for valid string', () {
      expect(LogicFlowType.fromvalue('m'), LogicFlowType.mutation);
      expect(LogicFlowType.fromvalue('r'), LogicFlowType.retrieval);
      expect(LogicFlowType.fromvalue('pag'), LogicFlowType.pagination);
    });

    test('fromvalue should return null for invalid string', () {
      expect(LogicFlowType.fromvalue('unknown'), isNull);
    });
  });
}
