import 'package:args/args.dart';
import 'package:fsda_cli/core/extensions/arg_results_x.dart';
import 'package:test/test.dart';

void main() {
  group('ArgResultsX.toMap', () {
    test(
      'GIVEN an ArgParser where no options are passed and no defaults are defined '
      'WHEN toMap is called '
      'THEN excludes null unparsed options and returns an empty map',
      () {
        // Given
        final parser = ArgParser()
          ..addOption('name')
          ..addOption('module');
        final results = parser.parse([]);

        // When
        final map = results.toMap();

        // Then
        expect(map, isEmpty);
      },
    );

    test(
      'GIVEN an ArgParser with default option and flag values not explicitly passed '
      'WHEN toMap is called '
      'THEN includes options with non-null default values',
      () {
        // Given
        final parser = ArgParser()
          ..addOption('org', defaultsTo: 'com.example')
          ..addFlag('force', defaultsTo: false)
          ..addOption('optional');
        final results = parser.parse([]);

        // When
        final map = results.toMap();

        // Then
        expect(map, {'org': 'com.example', 'force': false});
        expect(map.containsKey('optional'), isFalse);
      },
    );

    test(
      'GIVEN parsed single options, flags, and multi-options '
      'WHEN toMap is called '
      'THEN returns a map containing all parsed options and their values',
      () {
        // Given
        final parser = ArgParser()
          ..addOption('name')
          ..addFlag('verbose', negatable: false)
          ..addMultiOption('props')
          ..addOption('unparsed');
        final results = parser.parse([
          '--name',
          'task_entity',
          '--verbose',
          '--props',
          'String:title',
          '--props',
          'int:priority',
        ]);

        // When
        final map = results.toMap();

        // Then
        expect(map, {
          'name': 'task_entity',
          'verbose': true,
          'props': ['String:title', 'int:priority'],
        });
        expect(map.containsKey('unparsed'), isFalse);
      },
    );

    test(
      'GIVEN a flag with defaultsTo null that is explicitly parsed '
      'WHEN toMap is called '
      'THEN includes the explicitly parsed flag because wasParsed is true',
      () {
        // Given
        final parser = ArgParser()..addFlag('dry-run', defaultsTo: null);
        final results = parser.parse(['--no-dry-run']);

        // When
        final map = results.toMap();

        // Then
        expect(map, {'dry-run': false});
      },
    );
  });
}
