import 'package:fsda_cli/domain/models/dependency_metadata.dart'; // Sesuaikan path import dengan project Anda
import 'package:test/test.dart';

void main() {
  group('DependencyMetadata & DependencyParamMetadata', () {
    test('Given parameter metadata with default values and positional flag, '
        'When DependencyParamMetadata is instantiated, '
        'Then it holds the correct properties and default values', () {
      // Arrange (Given)
      const paramName = 'timeout';
      const paramType = 'int';
      const isNamed = true;
      const defaultValue = '30';

      // Act (When)
      const paramMetadata = DependencyParamMetadata(
        name: paramName,
        type: paramType,
        isNamed: isNamed,
        defaultValue: defaultValue,
      );

      // Assert (Then)
      expect(paramMetadata.name, equals(paramName));
      expect(paramMetadata.type, equals(paramType));
      expect(paramMetadata.isNamed, isTrue);
      expect(paramMetadata.defaultValue, equals(defaultValue));
    });

    test('Given dependency metadata with class name and parameters list, '
        'When DependencyMetadata is instantiated, '
        'Then it correctly stores the class name and parameters', () {
      // Arrange (Given)
      const className = 'ApiClient';
      const paramMetadata = DependencyParamMetadata(
        name: 'baseUrl',
        type: 'String',
      );

      // Act (When)
      const dependencyMetadata = DependencyMetadata(
        className: className,
        parameters: [paramMetadata],
      );

      // Assert (Then)
      expect(dependencyMetadata.className, equals(className));
      expect(dependencyMetadata.parameters, hasLength(1));
      expect(dependencyMetadata.parameters.first.name, equals('baseUrl'));
      expect(dependencyMetadata.parameters.first.type, equals('String'));
      expect(dependencyMetadata.parameters.first.isNamed, isFalse);
      expect(dependencyMetadata.parameters.first.defaultValue, isNull);
    });
  });
}
