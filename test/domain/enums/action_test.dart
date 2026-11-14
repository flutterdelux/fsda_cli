import 'package:fsda_cli/domain/enums/action.dart';
import 'package:test/test.dart';

void main() {
  group('Action Enum Tests', () {
    test('fromValue should return correct Action for valid string', () {
      expect(Action.fromValue('post'), Action.post);
      expect(Action.fromValue('get'), Action.get);
      expect(Action.fromValue('put'), Action.put);
      expect(Action.fromValue('patch'), Action.patch);
      expect(Action.fromValue('delete'), Action.delete);
    });

    test('fromValue should return null for invalid or unknown string', () {
      expect(Action.fromValue('unknown'), isNull);
      expect(Action.fromValue(''), isNull);
      expect(Action.fromValue('GET'), isNull);
    });
  });
}
