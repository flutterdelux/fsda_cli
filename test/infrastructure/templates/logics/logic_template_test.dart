import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/logic_template.dart';
import 'package:test/test.dart';

void main() {
  group('LogicTemplate', () {
    group('build (LogicParam)', () {
      test(
        'Given logic param with Cubit control, '
        'When build is called, '
        'Then it delegates and builds Cubit simple logic artifact correctly',
        () {
          // Arrange (Given)
          const logicParam = LogicParam(
            control: StateControl.cubit,
            props: [
              PropModel(
                name: 'title',
                type: 'String',
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
          final artifact = LogicTemplate.build(logicParam);

          // Assert (Then)
          expect(artifact.name, equals('CounterMainCubit'));
          expect(artifact.needToExport, isTrue);
          expect(
            artifact.content,
            contains('class CounterMainCubit extends Cubit<CounterMainState>'),
          );
        },
      );

      test(
        'Given logic param with GetX control, '
        'When build is called, '
        'Then it delegates and builds GetX simple logic artifact correctly',
        () {
          // Arrange (Given)
          const logicParam = LogicParam(
            control: StateControl.getx,
            props: [
              PropModel(
                name: 'title',
                type: 'String',
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
          final artifact = LogicTemplate.build(logicParam);

          // Assert (Then)
          expect(artifact.name, equals('CounterMainController'));
          expect(artifact.needToExport, isTrue);
          expect(
            artifact.content,
            contains('class CounterMainController extends GetxController'),
          );
        },
      );

      test(
        'Given logic param with Provider control, '
        'When build is called, '
        'Then it delegates and builds Provider simple logic artifact correctly',
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
            ],
            featureName: 'counter',
            featurePath: 'modules/app/lib/src/features/counter',
            moduleName: 'app',
            modulePath: 'modules/app',
            slice: 'main',
          );

          // Act (When)
          final artifact = LogicTemplate.build(logicParam);

          // Assert (Then)
          expect(artifact.name, equals('CounterMainProvider'));
          expect(artifact.needToExport, isTrue);
          expect(
            artifact.content,
            contains('class CounterMainProvider extends ChangeNotifier'),
          );
        },
      );

      test(
        'Given logic param with Riverpod control, '
        'When build is called, '
        'Then it delegates and builds Riverpod simple logic artifact correctly',
        () {
          // Arrange (Given)
          const logicParam = LogicParam(
            control: StateControl.riverpod,
            props: [
              PropModel(
                name: 'title',
                type: 'String',
                converter: '',
                defaultValue: '',
              ),
            ],
            featureName: 'counter',
            featurePath: 'modules/app/lib/src/features/counter',
            moduleName: 'app',
            modulePath: 'modules/app',
            slice: 'main',
          );

          // Act (When)
          final artifact = LogicTemplate.build(logicParam);

          // Assert (Then)
          expect(artifact.name, equals('CounterMainProvider'));
          expect(artifact.needToExport, isTrue);
          expect(
            artifact.content,
            contains(
              'class CounterMainProvider extends Notifier<CounterMainState>',
            ),
          );
        },
      );
    });

    group('buildFlow (LogicFlowParam)', () {
      test('Given logic flow param with GetX control and retrieval type, '
          'When buildFlow is called, '
          'Then it delegates and builds GetX flow artifact correctly', () {
        // Arrange (Given)
        const logicFlowParam = LogicFlowParam(
          type: LogicFlowType.retrieval,
          control: StateControl.getx,
          uc: LogicUcModel(
            name: 'user_detail_use_case',
            path:
                'modules/auth/lib/src/domain/usecases/user_detail_use_case.dart',
            type: UcType.returnUc,
            method: 'call',
            returnType: 'UserEntity',
          ),
          featureName: 'user',
          featurePath: 'modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: 'modules/auth',
          slice: 'detail',
        );

        // Act (When)
        final artifact = LogicTemplate.buildFlow(logicFlowParam);

        // Assert (Then)
        expect(artifact.name, equals('UserDetailController'));
        expect(artifact.needToExport, isTrue);
        expect(
          artifact.content,
          contains('class UserDetailController extends GetxController'),
        );
      });

      test('Given logic flow param with Riverpod control and retrieval type, '
          'When buildFlow is called, '
          'Then it delegates and builds Riverpod flow artifact correctly', () {
        // Arrange (Given)
        const logicFlowParam = LogicFlowParam(
          type: LogicFlowType.retrieval,
          control: StateControl.riverpod,
          uc: LogicUcModel(
            name: 'user_detail_use_case',
            path:
                'modules/auth/lib/src/domain/usecases/user_detail_use_case.dart',
            type: UcType.returnUc,
            method: 'call',
            returnType: 'UserEntity',
          ),
          featureName: 'user',
          featurePath: 'modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: 'modules/auth',
          slice: 'detail',
        );

        // Act (When)
        final artifact = LogicTemplate.buildFlow(logicFlowParam);

        // Assert (Then)
        expect(artifact.name, equals('UserDetailProvider'));
        expect(artifact.needToExport, isTrue);
        expect(
          artifact.content,
          contains(
            'class UserDetailProvider extends Notifier<UserDetailState>',
          ),
        );
      });
    });
  });
}
