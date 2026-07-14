import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final projectRoot = Directory.current.path;
  final templatesDir = Directory('$projectRoot/templates');

  if (!await templatesDir.exists()) {
    throw Exception('Templates directory not found: ${templatesDir.path}');
  }

  // Separate storage in memory for apps and packages from the beginning
  final appsData = <String, Map<String, String>>{};
  final packagesData = <String, Map<String, String>>{};

  await for (final entity in templatesDir.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File) continue;

    // Get the relative path starting from the /templates folder
    final relativePath = entity.path.substring(templatesDir.path.length + 1);
    final segments = relativePath.split(Platform.pathSeparator);

    // Minimum structure required: [category]/[template_name]/[file_path]
    if (segments.length < 3) continue;

    final category = segments[0]; // 'apps' or 'packages'
    final templateName = segments[1]; // Sub-folder template name
    final filePath = segments
        .skip(2)
        .join('/'); // The remaining internal file path

    final bytes = await entity.readAsBytes();
    final base64Content = base64Encode(bytes);

    if (category == 'apps') {
      appsData.putIfAbsent(templateName, () => <String, String>{});
      appsData[templateName]![filePath] = base64Content;
    } else if (category == 'packages') {
      packagesData.putIfAbsent(templateName, () => <String, String>{});
      packagesData[templateName]![filePath] = base64Content;
    }
  }

  final outputDir = Directory('$projectRoot/lib/generated');
  await outputDir.create(recursive: true);

  final packageFile = File('${outputDir.path}/package_bundle.dart');
  final packageBuffer = StringBuffer();
  packageBuffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  packageBuffer.writeln();
  packageBuffer.writeln('const packageBundle = <String, Map<String, String>>{');

  for (final templateEntry in packagesData.entries) {
    packageBuffer.writeln("  '${templateEntry.key}': <String, String>{");
    for (final fileEntry in templateEntry.value.entries) {
      // Normalize Windows backslashes (\) to POSIX standard forward slashes (/)
      final normalizedPath = fileEntry.key.replaceAll(r'\', '/');
      packageBuffer.writeln("    '$normalizedPath': '${fileEntry.value}',");
    }
    packageBuffer.writeln('  },');
  }
  packageBuffer.writeln('};');
  await packageFile.writeAsString(packageBuffer.toString());

  // --------------------------------------------------------------------------
  // LOG REPORT
  // --------------------------------------------------------------------------
  stdout.writeln('🎉 Execution completed successfully!');
  stdout.writeln(
    '   -> Generated packageBundle (${packagesData.length} templates) -> ${packageFile.path}',
  );
}
