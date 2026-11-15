import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/cubit_template.dart';
import 'package:test/test.dart';

void main() {
  group('CubitTemplate', () {
    test(
      'Given logic param with properties, '
      'When build is called, '
      'Then it generates cubit content with updateState method and correct properties and imports',
      () {
        // Arrange (Given)
        const logicParam = LogicParam(
          featureName: 'user_profile',
          featurePath: 'features/user_profile',
          moduleName: 'auth',
          modulePath: 'modules/auth',
          slice: 'edit',
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
        final artifact = CubitTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('UserProfileEditCubit'));
        expect(artifact.needToExport, isTrue);
        expect(artifact.typesToImport, containsAll(['String', 'int']));

        expect(
          artifact.content,
          contains(
            'class UserProfileEditCubit extends Cubit<UserProfileEditState>',
          ),
        );
        expect(
          artifact.content,
          contains(
            'UserProfileEditCubit() : super(const UserProfileEditState());',
          ),
        );
        expect(artifact.content, contains('void updateState({'));
        expect(artifact.content, contains('String firstName,'));
        expect(artifact.content, contains('int age,'));
        expect(artifact.content, contains('firstName: firstName,'));
        expect(artifact.content, contains('age: age,'));
      },
    );

    test(
      'Given logic param without properties, '
      'When build is called, '
      'Then it generates cubit content with empty updateState parameters',
      () {
        // Arrange (Given)
        const logicParam = LogicParam(
          featureName: 'settings',
          featurePath: 'features/settings',
          moduleName: 'app',
          modulePath: 'modules/app',
          slice: 'general',
          props: [],
        );

        // Act (When)
        final artifact = CubitTemplate.build(logicParam);

        // Assert (Then)
        expect(artifact.name, equals('SettingsGeneralCubit'));
        expect(artifact.needToExport, isTrue);
        expect(artifact.typesToImport, isEmpty);

        expect(
          artifact.content,
          contains(
            'class SettingsGeneralCubit extends Cubit<SettingsGeneralState>',
          ),
        );
        expect(artifact.content, contains('void updateState({\n    \n  })'));
      },
    );
  });
}
