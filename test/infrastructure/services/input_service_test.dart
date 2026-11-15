import 'package:fsda_cli/domain/params/inputs/input_dropdown_enum_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_dropdown_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_image_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_number_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_password_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_qty_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_selector_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_switch_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_text_area_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_text_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_resolver_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/input_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockArbService extends Mock implements ArbService {}

class MockImportResolverService extends Mock implements ImportResolverService {}

class MockImportService extends Mock implements ImportService {}

void main() {
  late InputService inputService;
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockArbService mockArbService;
  late MockImportResolverService mockImportResolverService;
  late MockImportService mockImportService;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockArbService = MockArbService();
    mockImportResolverService = MockImportResolverService();
    mockImportService = MockImportService();

    inputService = InputService(
      reportService: mockReportService,
      fileService: mockFileService,
      arbService: mockArbService,
      importResolverService: mockImportResolverService,
      importService: mockImportService,
    );
  });

  group('InputService Comprehensive Tests', () {
    void setupCommonMocks({Set<String>? resolvedImports}) {
      when(
        () => mockFileService.writeAsString(
          path: any(named: 'path'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockArbService.getArbPaths(any()),
      ).thenAnswer((_) async => ['/modules/auth/lib/l10n/app_en.arb']);
      when(
        () => mockArbService.injectEntriesBeforeKey(
          arbPath: any(named: 'arbPath'),
          endKey: any(named: 'endKey'),
          arbEntries: any(named: 'arbEntries'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockImportResolverService.resolve(
          rawTypes: any(named: 'rawTypes'),
          targetFilePath: any(named: 'targetFilePath'),
          modulePath: any(named: 'modulePath'),
        ),
      ).thenAnswer((_) async => resolvedImports ?? <String>{});
      when(
        () => mockImportService.injectImport(
          path: any(named: 'path'),
          imports: any(named: 'imports'),
        ),
      ).thenAnswer((_) async => {});
      when(() => mockReportService.addCreated(any())).thenReturn(null);
      when(() => mockReportService.addInjected(any())).thenReturn(null);
    }

    test('generateText executes successfully', () async {
      setupCommonMocks();
      final logs = <String>[];
      const inputTextParam = InputTextParam(
        featureName: 'auth',
        featurePath: '/modules/auth/lib/src/features/auth',
        moduleName: 'auth',
        modulePath: '/modules/auth',
        field: 'email',
      );
      await inputService.generateText(
        input: inputTextParam,
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test('generateTextArea executes successfully', () async {
      setupCommonMocks();
      final logs = <String>[];
      await inputService.generateTextArea(
        input: const InputTextAreaParam(
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          moduleName: 'auth',
          modulePath: '/modules/auth',
          field: 'testField',
        ),
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test('generateNumber executes successfully with imports', () async {
      setupCommonMocks(resolvedImports: {'package:test/test.dart'});
      final logs = <String>[];
      const inputNumberParam = InputNumberParam(
        featureName: 'auth',
        featurePath: '/modules/auth/lib/src/features/auth',
        moduleName: 'auth',
        modulePath: '/modules/auth',
        field: 'age',
        type: 'int', // wajib diisi
      );
      await inputService.generateNumber(
        input: inputNumberParam,
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test('generateSwitch executes successfully', () async {
      setupCommonMocks();
      final logs = <String>[];
      await inputService.generateSwitch(
        input: const InputSwitchParam(
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          moduleName: 'auth',
          modulePath: '/modules/auth',
          field: 'testField',
        ),
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test('generatePassword executes successfully', () async {
      setupCommonMocks();
      final logs = <String>[];
      await inputService.generatePassword(
        input: const InputPasswordParam(
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          moduleName: 'auth',
          modulePath: '/modules/auth',
          field: 'testField',
        ),
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test('generateQty executes successfully', () async {
      setupCommonMocks();
      final logs = <String>[];
      await inputService.generateQty(
        input: const InputQtyParam(
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          moduleName: 'auth',
          modulePath: '/modules/auth',
          field: 'testField',
        ),
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });
    test('generateImage executes successfully with imports', () async {
      setupCommonMocks(resolvedImports: {'package:image/image.dart'});
      final logs = <String>[];
      const inputImageParam = InputImageParam(
        featureName: 'auth',
        featurePath: '/modules/auth/lib/src/features/auth',
        moduleName: 'auth',
        modulePath: '/modules/auth',
        field: 'avatar',
        type: 'NetworkFile',
      );
      await inputService.generateImage(
        input: inputImageParam,
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test('generateDropdown executes successfully with imports', () async {
      setupCommonMocks(resolvedImports: {'package:model/model.dart'});
      final logs = <String>[];
      const inputDropdownParam = InputDropdownParam(
        featureName: 'auth',
        featurePath: '/modules/auth/lib/src/features/auth',
        moduleName: 'auth',
        modulePath: '/modules/auth',
        field: 'category',
        type: 'String',
      );
      await inputService.generateDropdown(
        input: inputDropdownParam,
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test('generateDropdownEnum executes successfully with imports', () async {
      setupCommonMocks(resolvedImports: {'package:enum/enum.dart'});
      final logs = <String>[];
      const inputDropdownEnumParam = InputDropdownEnumParam(
        featureName: 'auth',
        featurePath: '/modules/auth/lib/src/features/auth',
        moduleName: 'auth',
        modulePath: '/modules/auth',
        field: 'role',
        type: 'UserRole',
      );
      await inputService.generateDropdownEnum(
        input: inputDropdownEnumParam,
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test(
      'generateSelector executes successfully for single and list modes',
      () async {
        setupCommonMocks(resolvedImports: {'package:model/model.dart'});

        // Test non-list mode
        final logs1 = <String>[];
        const inputSelectorParam = InputSelectorParam(
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          moduleName: 'auth',
          modulePath: '/modules/auth',
          field: 'user',
          valueType: 'UserModel', // wajib diisi
          isList: false, // opsional (default false)
        );
        await inputService.generateSelector(
          input: inputSelectorParam,
          onProgress: (msg) => logs1.add(msg),
        );
        expect(logs1, isNotEmpty);

        // Test list mode
        final logs2 = <String>[];
        const inputSelectorListParam = InputSelectorParam(
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          moduleName: 'auth',
          modulePath: '/modules/auth',
          field: 'user',
          valueType: 'UserModel', // wajib diisi
          isList: true, // opsional (default false)
        );
        await inputService.generateSelector(
          input: inputSelectorListParam,
          onProgress: (msg) => logs2.add(msg),
        );
        expect(logs2, isNotEmpty);
      },
    );
  });
}
