import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:test/test.dart';

void main() {
  group('StateControl Tests', () {
    test('tryParse should return correct StateControl for valid string', () {
      expect(StateControl.tryParse('cubit'), StateControl.cubit);
      expect(StateControl.tryParse('getx'), StateControl.getx);
      expect(StateControl.tryParse('provider'), StateControl.provider);
      expect(StateControl.tryParse('riverpod'), StateControl.riverpod);
    });

    test('tryParse should return null for invalid string', () {
      expect(StateControl.tryParse('unknown'), isNull);
    });
  });
}
