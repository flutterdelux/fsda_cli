import 'package:fsda_cli/core/extensions/state_control_x.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:test/test.dart';

void main() {
  group('StateControl & StateControlX Tests', () {
    test('should return correct value from tryParse factory/method', () {
      expect(StateControl.tryParse('cubit'), StateControl.cubit);
      expect(StateControl.tryParse('getx'), StateControl.getx);
      expect(StateControl.tryParse('provider'), StateControl.provider);
      expect(StateControl.tryParse('riverpod'), StateControl.riverpod);
      expect(StateControl.tryParse('unknown'), isNull);
    });

    test('should return correct name string based on StateControl type', () {
      expect(StateControl.cubit.suffix, 'cubit');
      expect(StateControl.getx.suffix, 'controller');
      expect(StateControl.provider.suffix, 'provider');
      expect(StateControl.riverpod.suffix, 'provider');
    });

    test(
      'should return correct pascalCase namePascal based on StateControl type',
      () {
        expect(StateControl.cubit.suffixPascal, 'Cubit');
        expect(StateControl.getx.suffixPascal, 'Controller');
        expect(StateControl.provider.suffixPascal, 'Provider');
        expect(StateControl.riverpod.suffixPascal, 'Provider');
      },
    );
  });
}
