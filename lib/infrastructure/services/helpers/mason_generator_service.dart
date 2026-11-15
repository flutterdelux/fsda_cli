import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import 'directory_service.dart';
import 'operation_report_service.dart';

class MasonGeneratorService {
  final DirectoryService _directoryService;
  final OperationReportService _reportService;

  const MasonGeneratorService({
    required DirectoryService directoryService,
    required OperationReportService reportService,
  }) : _directoryService = directoryService,
       _reportService = reportService;

  Future<MasonGenerator> createGenerator(MasonBundle bundle) async {
    return await MasonGenerator.fromBundle(bundle);
  }

  Future<void> generate({
    required MasonBundle bundle,
    required String targetPath,
    required Map<String, dynamic> vars,
  }) async {
    try {
      final generator = await createGenerator(bundle);
      final generatedFiles = await generator.generate(
        DirectoryGeneratorTarget(_directoryService.dirOf(targetPath)),
        vars: vars,
      );

      for (final file in generatedFiles) {
        final filePath = file.path;

        if (filePath.endsWith('.freezed.dart') ||
            filePath.endsWith('.g.dart')) {
          continue;
        }

        if (filePath.endsWith('.gitkeep')) {
          final folderPath = p.dirname(filePath);
          _reportService.addCreated(folderPath);
          continue;
        }

        _reportService.addCreated(filePath);
      }
    } catch (e) {
      throw Exception('Failed to generate bundle files: $e');
    }
  }
}
