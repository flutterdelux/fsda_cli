import 'package:fsda_cli/domain/enums/action.dart';
import 'package:test/test.dart';

void main() {
  group('Action', () {
    test('GIVEN all Action enum values '
        'WHEN values and value property are accessed '
        'THEN returns expected string identifiers in declaration order', () {
      // When & Then
      expect(Action.values, [
        Action.post,
        Action.get,
        Action.put,
        Action.patch,
        Action.delete,
      ]);
      expect(Action.post.value, 'post');
      expect(Action.get.value, 'get');
      expect(Action.put.value, 'put');
      expect(Action.patch.value, 'patch');
      expect(Action.delete.value, 'delete');
    });

    group('tryParse', () {
      test('GIVEN valid Action string values '
          'WHEN tryParse is called '
          'THEN returns the corresponding Action enum member', () {
        // Given
        const cases = <String, Action>{
          'post': Action.post,
          'get': Action.get,
          'put': Action.put,
          'patch': Action.patch,
          'delete': Action.delete,
        };

        // When & Then
        cases.forEach((rawValue, expected) {
          expect(Action.tryParse(rawValue), expected);
        });
      });

      test('GIVEN invalid, uppercase, or empty string values '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidValues = ['unknown', '', 'GET', 'POST'];

        // When & Then
        for (final rawValue in invalidValues) {
          expect(Action.tryParse(rawValue), isNull);
        }
      });
    });

    group('available', () {
      test('GIVEN Action enum '
          'WHEN available getter is accessed '
          'THEN returns comma-separated list of all valid values', () {
        // When & Then
        expect(Action.available, 'post, get, put, patch, delete');
      });
    });
  });
}
