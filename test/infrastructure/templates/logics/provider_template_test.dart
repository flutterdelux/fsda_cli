import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/provider_template.dart';
import 'package:test/test.dart';

void main() {
  group('ProviderTemplate', () {
    test(
      'Given logic param with properties and Provider control, '
      'When build is called, '
      'Then it generates simple ChangeNotifier content with updateState method and notifyListeners',
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
        final artifact = ProviderTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('CounterMainProvider'));
        expect(artifact.needToExport, isTrue);
        expect(artifact.typesToImport, containsAll(['String', 'int']));

        expect(
          artifact.content,
          contains('class CounterMainProvider extends ChangeNotifier'),
        );
        expect(artifact.content, contains('void updateState({'));
        expect(artifact.content, contains('notifyListeners();'));
      },
    );
  });
}
