import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/state_template.dart';
import 'package:test/test.dart';

void main() {
  group('StateTemplate', () {
    test(
      'Given logic param with custom properties, '
      'When build is called, '
      'Then it generates Freezed state content with correct property definitions, defaults, and requirements',
      () {
        // Arrange (Given)
        const logicParam = LogicParam(
          control: StateControl.provider,
          props: [
            PropModel(
              name: 'title',
              type: 'String',
              defaultValue: '',
              converter: '',
            ),
            PropModel(
              name: 'count',
              type: 'int',
              defaultValue: '0',
              converter: '',
            ),
            PropModel(
              name: 'description',
              type: 'String?',
              defaultValue: '',
              converter: '',
            ),
          ],
          featureName: 'counter',
          featurePath: 'modules/app/lib/src/features/counter',
          moduleName: 'app',
          modulePath: 'modules/app',
          slice: 'main',
        );

        // Act (When)
        final artifact = StateTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('CounterMainState'));
        expect(artifact.needToExport, isTrue);
        expect(
          artifact.typesToImport,
          containsAll(['String', 'int', 'String?']),
        );

        expect(
          artifact.content,
          contains('sealed class CounterMainState with _\$CounterMainState'),
        );
        expect(artifact.content, contains('required String title,'));
        expect(artifact.content, contains('@Default(0) int count,'));
        expect(artifact.content, contains('String? description,'));
      },
    );
  });
}
