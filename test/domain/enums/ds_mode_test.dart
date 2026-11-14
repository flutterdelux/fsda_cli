import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:test/test.dart';

void main() {
  group('DsMode Tests', () {
    test('fromValue should return correct DsMode for valid string', () {
      expect(DsMode.fromValue('local'), DsMode.local);
      expect(DsMode.fromValue('remote'), DsMode.remote);
    });

    test('fromValue should return null for invalid string', () {
      expect(DsMode.fromValue('unknown'), isNull);
      expect(DsMode.fromValue(''), isNull);
    });
  });
}
