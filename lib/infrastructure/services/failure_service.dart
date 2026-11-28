import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import '../../core/extensions/failure_param_x.dart';
import '../../core/extensions/module_param_x.dart';
import '../../domain/params/failure_param.dart';
import '../templates/failure_template.dart';
import '../visitors/switch_expression_visitor.dart';
import '../visitors/switch_statement_visitor.dart';
import '../visitors/when_arguments_visitor.dart';
import 'helpers/arb_service.dart';
import 'helpers/file_service.dart';
import 'helpers/operation_report_service.dart';

class FailureService {
  final OperationReportService _reportService;
  final FileService _fileService;
  final ArbService _arbService;

  const FailureService({
    required OperationReportService reportService,
    required FileService fileService,
    required ArbService arbService,
  }) : _reportService = reportService,
       _fileService = fileService,
       _arbService = arbService;

  Future<void> generate({
    required FailureParam failureParam,
    required Function(String) onProgress,
  }) async {
    onProgress(
      'Injecting exception factory, message, toFailure, and code response at the end...',
    );
    await _injectException(failureParam);

    onProgress('Injecting failure enum value at the end...');
    await _injectFailureEnum(failureParam);

    onProgress('Injecting localize entry in failure extension at the end...');
    await _injectFailureExtension(failureParam);

    onProgress('Injecting localization keys into ARB files...');
    await _injectFailureArb(failureParam);
  }

  // ================= Helper with AST Visitor =================
  // ================= Helper with AST Visitor =================
  Future<void> _injectException(FailureParam failureParam) async {
    final path = failureParam.exceptionPath;
    String content = await _fileService.readAsString(path);
    final initialContent = content;
    final result = parseString(content: content);
    final unit = result.unit;

    final targetFactoryName = failureParam.nameCamel;
    final targetCodeConstant = "'${failureParam.nameScreaming}'";

    bool hasFactory = false;
    int? lastFactoryEndOffset;

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        for (final member in declaration.body.members) {
          if (member is ConstructorDeclaration &&
              member.factoryKeyword != null) {
            if (member.name?.lexeme == targetFactoryName) {
              hasFactory = true;
            }
            lastFactoryEndOffset = member.end;
          }
        }
      }
    }

    // 1. Injeksi constructor factory jika belum ada
    if (!hasFactory && lastFactoryEndOffset != null) {
      final factoryCode = FailureTemplate.buildFactory(failureParam);
      content =
          '${content.substring(0, lastFactoryEndOffset)}\n\n$factoryCode${content.substring(lastFactoryEndOffset)}';
    }

    final updatedResult = parseString(content: content);
    final updatedUnit = updatedResult.unit;

    int? messageInsertOffset;
    int? toFailureInsertOffset;
    int? switchInsertOffset;
    bool hasMessageEntry = false;
    bool hasToFailureEntry = false;
    bool hasSwitchCase = false;

    for (final declaration in updatedUnit.declarations) {
      if (declaration is ClassDeclaration) {
        for (final member in declaration.body.members) {
          if (member is MethodDeclaration) {
            // Cek & cari offset pada getter `message => when(...)`
            if (member.name.lexeme == 'message') {
              hasMessageEntry = member.toSource().contains(
                '$targetFactoryName:',
              );
              if (!hasMessageEntry) {
                member.visitChildren(
                  WhenArgumentsVisitor(
                    (offset) => messageInsertOffset = offset,
                  ),
                );
              }
            }
            // Cek & cari offset pada method `toFailure() => when(...)`
            if (member.name.lexeme == 'toFailure') {
              hasToFailureEntry = member.toSource().contains(
                '$targetFactoryName:',
              );
              if (!hasToFailureEntry) {
                member.visitChildren(
                  WhenArgumentsVisitor(
                    (offset) => toFailureInsertOffset = offset,
                  ),
                );
              }
            }
            // Cek & cari offset pada `fromApiResponse`
            if (member.name.lexeme == 'fromApiResponse') {
              hasSwitchCase = member.toSource().contains(targetCodeConstant);
              if (!hasSwitchCase) {
                member.visitChildren(
                  SwitchStatementVisitor(
                    (offset) => switchInsertOffset = offset,
                  ),
                );
              }
            }
          }
        }
      }
    }

    // 2. Injeksi ke getter message jika belum ada
    if (!hasMessageEntry && messageInsertOffset != null) {
      final messageCode = FailureTemplate.buildMessage(failureParam);
      final preceding = content.substring(0, messageInsertOffset).trimRight();
      final needComma = !preceding.endsWith(',');
      final comma = needComma ? ',' : '';

      content =
          '${content.substring(0, messageInsertOffset)}$comma\n    $messageCode\n  ${content.substring(messageInsertOffset!)}';
    }

    // 3. Injeksi ke method toFailure jika belum ada
    if (!hasToFailureEntry && toFailureInsertOffset != null) {
      final reParsedResult = parseString(content: content);
      int? recomputedToFailureOffset;
      for (final declaration in reParsedResult.unit.declarations) {
        if (declaration is ClassDeclaration) {
          for (final member in declaration.body.members) {
            if (member is MethodDeclaration &&
                member.name.lexeme == 'toFailure') {
              member.visitChildren(
                WhenArgumentsVisitor(
                  (offset) => recomputedToFailureOffset = offset,
                ),
              );
            }
          }
        }
      }

      final targetOffset = recomputedToFailureOffset ?? toFailureInsertOffset;
      final toFailureCode = FailureTemplate.buildToFailure(failureParam);

      final precedingToFailure = content.substring(0, targetOffset).trimRight();
      final needCommaToFailure = !precedingToFailure.endsWith(',');
      final commaToFailure = needCommaToFailure ? ',' : '';

      content =
          '${content.substring(0, targetOffset)}$commaToFailure\n    $toFailureCode\n  ${content.substring(targetOffset!)}';
    }

    // 4. Injeksi ke switch case fromApiResponse jika belum ada
    if (!hasSwitchCase && switchInsertOffset != null) {
      final reParsedResult2 = parseString(content: content);
      int? recomputedSwitchOffset;
      for (final declaration in reParsedResult2.unit.declarations) {
        if (declaration is ClassDeclaration) {
          for (final member in declaration.body.members) {
            if (member is MethodDeclaration &&
                member.name.lexeme == 'fromApiResponse') {
              member.visitChildren(
                SwitchStatementVisitor(
                  (offset) => recomputedSwitchOffset = offset,
                ),
              );
            }
          }
        }
      }

      final targetSwitchOffset = recomputedSwitchOffset ?? switchInsertOffset;
      final codeResponseCode = FailureTemplate.buildCodeResponse(failureParam);
      content =
          '${content.substring(0, targetSwitchOffset)}${codeResponseCode.trimLeft()}${' ' * 8}${content.substring(targetSwitchOffset!)}';
    }

    // Simpan hanya jika ada perubahan
    if (content != initialContent) {
      await _fileService.writeAsString(path: path, content: content);
      _reportService.addInjected(path);
    }
  }

  Future<void> _injectFailureEnum(FailureParam failureParam) async {
    final path = failureParam.failurePath;
    String content = await _fileService.readAsString(path);
    final result = parseString(content: content);
    final unit = result.unit;

    final targetEnumName = failureParam.nameCamel;
    int? enumBodyEndOffset;

    for (final declaration in unit.declarations) {
      if (declaration is EnumDeclaration) {
        // Skip jika nilai enum sudah terdaftar
        final alreadyExists = declaration.body.constants.any(
          (constant) => constant.name.lexeme == targetEnumName,
        );
        if (alreadyExists) return;

        enumBodyEndOffset = declaration.endToken.offset;
        break;
      }
    }

    if (enumBodyEndOffset != null) {
      final enumValueCode = FailureTemplate.buildEnumValue(failureParam);
      final precedingEnum = content.substring(0, enumBodyEndOffset).trimRight();
      final needEnumComma = !precedingEnum.endsWith(',');
      final enumComma = needEnumComma ? ',' : '';

      content =
          '${content.substring(0, enumBodyEndOffset)}$enumComma\n  $enumValueCode\n${content.substring(enumBodyEndOffset)}';

      await _fileService.writeAsString(path: path, content: content);
      _reportService.addInjected(path);
    }
  }

  Future<void> _injectFailureExtension(FailureParam failureParam) async {
    final path = failureParam.extensionPath;
    String content = await _fileService.readAsString(path);
    final result = parseString(content: content);
    final unit = result.unit;

    final targetEnumMember = '.${failureParam.nameCamel}';
    int? extensionSwitchInsertOffset;

    for (final declaration in unit.declarations) {
      if (declaration is ExtensionDeclaration) {
        for (final member in declaration.body.members) {
          if (member is MethodDeclaration && member.name.lexeme == 'localize') {
            // Skip jika case enum sudah ada di dalam localize()
            if (member.toSource().contains(targetEnumMember)) return;

            member.visitChildren(
              SwitchExpressionVisitor((insertOffset) {
                extensionSwitchInsertOffset = insertOffset;
              }),
            );
          }
        }
      }
    }

    if (extensionSwitchInsertOffset != null) {
      final localizeCode = FailureTemplate.buildItemLocalizeX(failureParam);
      final preceding = content
          .substring(0, extensionSwitchInsertOffset)
          .trimRight();
      final needComma = !preceding.endsWith(',');
      final comma = needComma ? ',' : '';

      content =
          '${content.substring(0, extensionSwitchInsertOffset)}$comma\n      $localizeCode,\n    ${content.substring(extensionSwitchInsertOffset!)}';

      await _fileService.writeAsString(path: path, content: content);
      _reportService.addInjected(path);
    }
  }

  Future<void> _injectFailureArb(FailureParam failureParam) async {
    final arbPaths = await _arbService.getArbPaths(failureParam.modulePath);
    final arbEntries = FailureTemplate.buildArbEntries(failureParam);
    final endKey = FailureTemplate.endDividerArbKey();
    for (final arbPath in arbPaths) {
      await _arbService.injectEntriesBeforeKey(
        arbPath: arbPath,
        arbEntries: arbEntries,
        endKey: endKey,
      );
      _reportService.addInjected(arbPath);
    }
  }
}
