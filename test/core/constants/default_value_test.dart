import 'package:fsda_cli/core/constants/default_value.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultValue', () {
    group('fromType', () {
      test(
        "Given basic primitive and core types ('String', 'int', 'bool', etc.), "
        'When fromType is called, '
        'Then it returns the correct default value string',
        () {
          // Act & Assert (Given & When & Then disatukan karena berupa lookup sederhana)
          expect(DefaultValue.fromType('String'), equals(''));
          expect(DefaultValue.fromType('int'), equals('0'));
          expect(DefaultValue.fromType('double'), equals('0.0'));
          expect(DefaultValue.fromType('bool'), equals('false'));
          expect(DefaultValue.fromType('num'), equals('0'));
          expect(DefaultValue.fromType('DateTime'), equals('DateTime.now()'));
          expect(
            DefaultValue.fromType('Duration'),
            equals('Duration(seconds: 1)'),
          );
          expect(
            DefaultValue.fromType('Uri'),
            equals("Uri.parse('https:www.google.com')"),
          );
        },
      );

      test(
        "Given collection and function types ('List', 'Map', 'Set', 'Function', etc.), "
        'When fromType is called, '
        'Then it returns the correct collection or callback default string',
        () {
          expect(DefaultValue.fromType('List'), equals('[]'));
          expect(DefaultValue.fromType('Map'), equals('{}'));
          expect(DefaultValue.fromType('Set'), equals('{}'));
          expect(DefaultValue.fromType('Function'), equals('() {}'));
          expect(DefaultValue.fromType('Future<void>'), equals('() async {}'));
          expect(DefaultValue.fromType('VoidCallback'), equals('() {}'));
        },
      );

      test(
        "Given special system and IO types ('File', 'Directory', 'Failure', etc.), "
        'When fromType is called, '
        'Then it returns the corresponding instantiation or object default string',
        () {
          expect(
            DefaultValue.fromType('Failure'),
            equals('CoreFailure.serverError'),
          );
          expect(DefaultValue.fromType('Uint8List'), equals('[]'));
          expect(DefaultValue.fromType('File'), equals("File('')"));
          expect(DefaultValue.fromType('Directory'), equals("Directory('')"));
        },
      );

      test('Given an unknown or unsupported type, '
          'When fromType is called, '
          'Then it returns an empty string as fallback', () {
        expect(DefaultValue.fromType('UnknownCustomModel'), equals(''));
        expect(DefaultValue.fromType(''), equals(''));
      });
    });
  });
}
