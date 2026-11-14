import 'dart:io';

import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

class FakeFileSystemEntity extends Mock implements FileSystemEntity {
  final String _path;
  FakeFileSystemEntity(this._path);

  @override
  String get path => _path;
}

void main() {
  late ArbService arbService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;

  setUp(() {
    mockDirectoryService = MockDirectoryService();
    mockFileService = MockFileService();
    arbService = ArbService(
      directoryService: mockDirectoryService,
      fileService: mockFileService,
    );
  });

  group('ArbService Tests', () {
    const arbPath = 'lib/l10n/app_en.arb';

    test(
      'injectBySnippet should append snippet correctly when closing brace exists',
      () async {
        // Arrange
        const initialContent = '{\n  "hello": "Hello"\n}';
        const snippet = '  "world": "World"';

        when(
          () => mockFileService.readAsString(arbPath),
        ).thenAnswer((_) async => initialContent);
        when(
          () => mockFileService.writeAsString(
            path: arbPath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await arbService.injectBySnippet(arbPath: arbPath, arbSnippet: snippet);

        // Assert
        verify(() => mockFileService.readAsString(arbPath)).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: arbPath,
            content: '''{
  "hello": "Hello",
  "world": "World"}''',
          ),
        ).called(1);
      },
    );

    test(
      'unjectBetweenKeys should remove keys between startKey and endKey inclusive',
      () async {
        // Arrange
        const initialContent = '''{
  "key1": "Value 1",
  "startKey": "Start",
  "middleKey": "Middle",
  "endKey": "End",
  "key2": "Value 2"
}''';

        when(
          () => mockFileService.readAsString(arbPath),
        ).thenAnswer((_) async => initialContent);
        when(
          () => mockFileService.writeAsString(
            path: arbPath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await arbService.unjectBetweenKeys(
          arbPath: arbPath,
          startKey: 'startKey',
          endKey: 'endKey',
        );

        // Assert
        verify(() => mockFileService.readAsString(arbPath)).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: arbPath,
            content: any(
              named: 'content',
              that: predicate<String>(
                (content) =>
                    !content.contains('startKey') &&
                    !content.contains('middleKey') &&
                    !content.contains('endKey') &&
                    content.contains('key1') &&
                    content.contains('key2'),
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'injectEntriesBeforeKey should insert entries before endKey if it exists',
      () async {
        // Arrange
        const initialContent = '''{
  "existingKey": "Value"
}''';
        final newEntries = {'newKey': 'New Value'};

        when(
          () => mockFileService.readAsString(arbPath),
        ).thenAnswer((_) async => initialContent);
        when(
          () => mockFileService.writeAsString(
            path: arbPath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await arbService.injectEntriesBeforeKey(
          arbPath: arbPath,
          endKey: 'existingKey',
          arbEntries: newEntries,
        );

        // Assert
        verify(() => mockFileService.readAsString(arbPath)).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: arbPath,
            content: any(
              named: 'content',
              that: predicate<String>(
                (content) =>
                    content.indexOf('newKey') < content.indexOf('existingKey'),
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'injectEntriesBeforeKey should fallback and add entries if endKey does not exist',
      () async {
        // Arrange
        const initialContent = '''{
  "existingKey": "Value"
}''';
        final newEntries = {'newKey': 'New Value'};

        when(
          () => mockFileService.readAsString(arbPath),
        ).thenAnswer((_) async => initialContent);
        when(
          () => mockFileService.writeAsString(
            path: arbPath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await arbService.injectEntriesBeforeKey(
          arbPath: arbPath,
          endKey: 'nonExistentKey',
          arbEntries: newEntries,
        );

        // Assert
        verify(() => mockFileService.readAsString(arbPath)).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: arbPath,
            content: any(
              named: 'content',
              that: predicate<String>(
                (content) =>
                    content.contains('newKey') &&
                    content.contains('existingKey'),
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'unjectEntries should remove specified keys when they exist',
      () async {
        // Arrange
        const initialContent = '''{
  "keyToRemove": "Value",
  "keepKey": "Value"
}''';
        final entriesToRemove = {'keyToRemove': 'Value'};

        when(
          () => mockFileService.readAsString(arbPath),
        ).thenAnswer((_) async => initialContent);
        when(
          () => mockFileService.writeAsString(
            path: arbPath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await arbService.unjectEntries(
          arbPath: arbPath,
          arbEntries: entriesToRemove,
        );

        // Assert
        verify(() => mockFileService.readAsString(arbPath)).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: arbPath,
            content: any(
              named: 'content',
              that: predicate<String>(
                (content) =>
                    !content.contains('keyToRemove') &&
                    content.contains('keepKey'),
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'getArbPaths should return list of arb file paths from directory service and evaluate filter callback',
      () async {
        // Arrange
        const modulePath = '/path/to/module';
        const expectedPaths = ['/path/to/module/lib/l10n/app_en.arb'];

        when(
          () => mockDirectoryService.listFilePaths(
            dirPath: any(named: 'dirPath'),
            where: any(named: 'where'),
          ),
        ).thenAnswer((invocation) async {
          // Menangkap dan mengeksekusi callback 'where' agar tercakup dalam laporan coverage
          final where =
              invocation.namedArguments[#where]
                  as bool Function(FakeFileSystemEntity, bool)?;
          if (where != null) {
            where(FakeFileSystemEntity('app_en.arb'), true);
            where(FakeFileSystemEntity('app_en.txt'), true);
            where(FakeFileSystemEntity('app_en.arb'), false);
          }
          return expectedPaths;
        });

        // Act
        final result = await arbService.getArbPaths(modulePath);

        // Assert
        expect(result, expectedPaths);
        verify(
          () => mockDirectoryService.listFilePaths(
            dirPath: any(named: 'dirPath'),
            where: any(named: 'where'),
          ),
        ).called(1);
      },
    );
  });
}
