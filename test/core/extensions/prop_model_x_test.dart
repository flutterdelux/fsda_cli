import 'package:fsda_cli/core/extensions/prop_model_x.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:test/test.dart';

void main() {
  group('PropModelX', () {
    test(
      'GIVEN a PropModel instance with a non-empty converter '
      'WHEN noConverter getter is accessed '
      'THEN returns a new PropModel preserving type, name, and defaultValue with an empty converter',
      () {
        // Given
        const model = PropModel(
          type: 'DateTime',
          name: 'created_at',
          defaultValue: 'null',
          converter: 'UtcDateTimeConverter',
        );

        // When
        final result = model.noConverter;

        // Then
        expect(result.type, model.type);
        expect(result.name, model.name);
        expect(result.defaultValue, model.defaultValue);
        expect(result.converter, isEmpty);
      },
    );

    test(
      'GIVEN a PropModel instance that already has an empty converter '
      'WHEN noConverter getter is accessed '
      'THEN returns a PropModel with identical properties and an empty converter',
      () {
        // Given
        const model = PropModel(
          type: 'String',
          name: 'user_name',
          defaultValue: '',
          converter: '',
        );

        // When
        final result = model.noConverter;

        // Then
        expect(result.type, 'String');
        expect(result.name, 'user_name');
        expect(result.defaultValue, '');
        expect(result.converter, isEmpty);
      },
    );
  });
}
