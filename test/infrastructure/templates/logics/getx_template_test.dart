import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/getx_template.dart';
import 'package:test/test.dart';

void main() {
  group('GetxTemplate', () {
    test(
      'Given logic param with properties and GetX control, '
      'When build is called, '
      'Then it generates GetX controller content with private observable state, updateState method, and workspace path',
      () {
        // Arrange (Given)
        const logicParam = LogicParam(
          featureName: 'user_profile',
          featurePath: 'modules/auth/lib/src/features/user_profile',
          moduleName: 'auth',
          modulePath: 'modules/auth',
          slice: 'edit',
          control: StateControl.getx,
          props: [
            PropModel(
              name: 'first_name',
              type: 'String',
              defaultValue: '',
              converter: '',
            ),
            PropModel(
              name: 'age',
              type: 'int',
              defaultValue: '',
              converter: '',
            ),
          ],
        );

        // Act (When)
        final artifact = GetxTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserProfileEditController'));
        expect(artifact.needToExport, isTrue);
        expect(artifact.typesToImport, containsAll(['String', 'int']));
        expect(
          artifact.path,
          contains('modules/auth/lib/src/features/user_profile'),
        );

        expect(
          artifact.content,
          contains('class UserProfileEditController extends GetxController'),
        );
        expect(
          artifact.content,
          contains(
            'final Rx<UserProfileEditState> _state = const UserProfileEditState().obs;',
          ),
        );
        expect(artifact.content, contains('void updateState({'));
        expect(artifact.content, contains('String firstName,'));
        expect(artifact.content, contains('int age,'));
        expect(
          artifact.content,
          contains('_state.value = UserProfileEditState('),
        );
        expect(artifact.content, contains('firstName: firstName,'));
        expect(artifact.content, contains('age: age,'));
      },
    );

    test(
      'Given logic param without properties and GetX control, '
      'When build is called, '
      'Then it generates GetX controller content with empty updateState parameters',
      () {
        // Arrange (Given)
        const logicParam = LogicParam(
          featureName: 'settings',
          featurePath: 'modules/app/lib/src/features/settings',
          moduleName: 'app',
          modulePath: 'modules/app',
          slice: 'general',
          control: StateControl.getx,
          props: [],
        );

        // Act (When)
        final artifact = GetxTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('SettingsGeneralController'));
        expect(artifact.needToExport, isTrue);
        expect(artifact.typesToImport, isEmpty);

        expect(
          artifact.content,
          contains('class SettingsGeneralController extends GetxController'),
        );
        expect(artifact.content, contains('void updateState({\n    \n  })'));
      },
    );
  });
}
