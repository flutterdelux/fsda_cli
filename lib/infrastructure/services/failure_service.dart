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
  Future<void> _injectException(FailureParam failureParam) async {
    final path = failureParam.exceptionPath;
    String content = await _fileService.readAsString(path);
    final result = parseString(content: content);
    final unit = result.unit;

    int? lastFactoryEndOffset;

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        for (final member in declaration.body.members) {
          if (member is ConstructorDeclaration &&
              member.factoryKeyword != null) {
            lastFactoryEndOffset = member.end;
          }
        }
      }
    }

    // 1. Injeksi constructor factory di bagian atas (setelah factory terakhir)
    if (lastFactoryEndOffset != null) {
      final factoryCode = FailureTemplate.buildFactory(failureParam);
      content =
          '${content.substring(0, lastFactoryEndOffset)}\n\n$factoryCode${content.substring(lastFactoryEndOffset)}';
    }

    final updatedResult = parseString(content: content);
    final updatedUnit = updatedResult.unit;

    int? messageInsertOffset;
    int? toFailureInsertOffset;
    int? switchInsertOffset;

    for (final declaration in updatedUnit.declarations) {
      if (declaration is ClassDeclaration) {
        for (final member in declaration.body.members) {
          if (member is MethodDeclaration) {
            // Cari getter `message => when(...)`
            if (member.name.lexeme == 'message') {
              member.visitChildren(
                WhenArgumentsVisitor((offset) => messageInsertOffset = offset),
              );
            }
            // Cari method `toFailure() => when(...)`
            if (member.name.lexeme == 'toFailure') {
              member.visitChildren(
                WhenArgumentsVisitor(
                  (offset) => toFailureInsertOffset = offset,
                ),
              );
            }
            // Cari `fromApiResponse` untuk menyisipkan *switch case* sebelum default `_ =>`
            if (member.name.lexeme == 'fromApiResponse') {
              member.visitChildren(
                SwitchStatementVisitor((offset) => switchInsertOffset = offset),
              );
            }
          }
        }
      }
    }

    // 2. Injeksi ke getter message di bagian akhir argumen when()
    if (messageInsertOffset != null) {
      final messageCode = FailureTemplate.buildMessage(failureParam);
      // Cek apakah sebelum penutupan kurung sudah ada koma atau belum
      final preceding = content.substring(0, messageInsertOffset).trimRight();
      final needComma = !preceding.endsWith(',');
      final comma = needComma ? ',' : '';

      content =
          '${content.substring(0, messageInsertOffset)}$comma\n    $messageCode\n  ${content.substring(messageInsertOffset!)}';
    }

    // Re-parse ulang karena ada perubahan panjang string dari message
    if (toFailureInsertOffset != null) {
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

      // Cek trailing comma untuk toFailure
      final precedingToFailure = content.substring(0, targetOffset).trimRight();
      final needCommaToFailure = !precedingToFailure.endsWith(',');
      final commaToFailure = needCommaToFailure ? ',' : '';

      content =
          '${content.substring(0, targetOffset)}$commaToFailure\n    $toFailureCode\n  ${content.substring(targetOffset!)}';
    }

    // Re-parse ulang untuk switch case fromApiResponse
    if (switchInsertOffset != null) {
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

    await _fileService.writeAsString(path: path, content: content);
    _reportService.addInjected(path);
  }

  Future<void> _injectFailureEnum(FailureParam failureParam) async {
    final path = failureParam.failurePath;
    String content = await _fileService.readAsString(path);
    final result = parseString(content: content);
    final unit = result.unit;

    int? enumBodyEndOffset;

    for (final declaration in unit.declarations) {
      if (declaration is EnumDeclaration) {
        enumBodyEndOffset = declaration.endToken.offset;
        break;
      }
    }

    if (enumBodyEndOffset != null) {
      final enumValueCode = FailureTemplate.buildEnumValue(failureParam);
      // Cek apakah nilai enum sebelumnya sudah diakhiri dengan koma
      final precedingEnum = content.substring(0, enumBodyEndOffset).trimRight();
      final needEnumComma = !precedingEnum.endsWith(',');
      final enumComma = needEnumComma ? ',' : '';

      content =
          '${content.substring(0, enumBodyEndOffset)}$enumComma\n  $enumValueCode\n${content.substring(enumBodyEndOffset)}';
    }

    await _fileService.writeAsString(path: path, content: content);
    _reportService.addInjected(path);
  }

  Future<void> _injectFailureExtension(FailureParam failureParam) async {
    final path = failureParam.extensionPath;
    String content = await _fileService.readAsString(path);
    final result = parseString(content: content);
    final unit = result.unit;

    int? extensionSwitchInsertOffset;

    for (final declaration in unit.declarations) {
      if (declaration is ExtensionDeclaration) {
        for (final member in declaration.body.members) {
          if (member is MethodDeclaration && member.name.lexeme == 'localize') {
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
    }

    await _fileService.writeAsString(path: path, content: content);
    _reportService.addInjected(path);
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
