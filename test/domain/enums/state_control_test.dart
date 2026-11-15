import 'package:fsda_cli/domain/enums/state_control.dart'; // Sesuaikan path import dengan project Anda
import 'package:test/test.dart';

void main() {
  group('StateControl Enum', () {
    test('Given valid and invalid string values, '
        'When tryParse is called, '
        'Then it returns the correct StateControl instance or null', () {
      // Act & Assert (Given & When & Then)
      expect(StateControl.tryParse('cubit'), equals(StateControl.cubit));
      expect(StateControl.tryParse('getx'), equals(StateControl.getx));
      expect(StateControl.tryParse('provider'), equals(StateControl.provider));
      expect(StateControl.tryParse('riverpod'), equals(StateControl.riverpod));
      expect(StateControl.tryParse('unknown'), isNull);
      expect(StateControl.tryParse(null), isNull);
    });

    test('Given known and unknown parent class names, '
        'When parseFromExtends is called, '
        'Then it returns the corresponding StateControl or null', () {
      expect(
        StateControl.parseFromExtends('Cubit'),
        equals(StateControl.cubit),
      );
      expect(
        StateControl.parseFromExtends('GetxController'),
        equals(StateControl.getx),
      );
      expect(
        StateControl.parseFromExtends('ChangeNotifier'),
        equals(StateControl.provider),
      );
      expect(
        StateControl.parseFromExtends('Notifier'),
        equals(StateControl.riverpod),
      );
      expect(StateControl.parseFromExtends('UnknownClass'), isNull);
    });

    test('When available getter is called, '
        'Then it returns a comma-separated string of all enum values', () {
      expect(StateControl.available, equals('cubit, getx, provider, riverpod'));
    });
  });
}
