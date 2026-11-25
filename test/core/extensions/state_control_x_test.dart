import 'package:fsda_cli/core/extensions/state_control_x.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:test/test.dart';

void main() {
  group('StateControlX', () {
    test(
      'GIVEN all StateControl enum values '
      'WHEN suffix getter is accessed '
      'THEN returns the expected lowercase suffix for each state control',
      () {
        // Given & When & Then
        expect(StateControl.cubit.suffix, 'cubit');
        expect(StateControl.getx.suffix, 'controller');
        expect(StateControl.provider.suffix, 'provider');
        expect(StateControl.riverpod.suffix, 'provider');
      },
    );

    test('GIVEN all StateControl enum values '
        'WHEN suffixPascal getter is accessed '
        'THEN returns the PascalCase suffix for each state control', () {
      // Given & When & Then
      expect(StateControl.cubit.suffixPascal, 'Cubit');
      expect(StateControl.getx.suffixPascal, 'Controller');
      expect(StateControl.provider.suffixPascal, 'Provider');
      expect(StateControl.riverpod.suffixPascal, 'Provider');
    });
  });
}
