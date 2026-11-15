import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/riverpod_template.dart';
import 'package:test/test.dart';

void main() {
  group('RiverpodTemplate', () {
    test(
      'Given logic param with properties and Riverpod control, '
      'When build is called, '
      'Then it generates simple Notifier content with updateState method',
      () {
        // Arrange (Given)
        const logicParam = LogicParam(
          control: StateControl.riverpod,
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
        final artifact = RiverpodTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('CounterMainProvider'));
        expect(artifact.needToExport, isTrue);
        expect(artifact.typesToImport, containsAll(['String', 'int']));

        expect(
          artifact.content,
          contains(
            'class CounterMainProvider extends Notifier<CounterMainState>',
          ),
        );
        expect(artifact.content, contains('void updateState({'));
        expect(artifact.content, contains('state = CounterMainState('));
      },
    );
  });
}
