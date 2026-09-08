import 'dart:io';

import '../enums/compose_page_mode.dart';
import 'base_generator.dart';
import 'compose/compose_main_service.dart';
import 'compose/compose_pag_service.dart';
import 'compose/compose_pmi_service.dart';
import 'compose/compose_types.dart';

class ComposeGenerator extends BaseGenerator<void, ComposeArgs> {
  final ComposeMainService mainService;
  final ComposePagService pagService;
  final ComposePmiService pmiService;

  ComposeGenerator({
    required super.logger,
    ComposeMainService? mainService,
    ComposePagService? pagService,
    ComposePmiService? pmiService,
  }) : mainService = mainService ?? ComposeMainService(logger: logger),
       pagService = pagService ?? ComposePagService(logger: logger),
       pmiService = pmiService ?? ComposePmiService(logger: logger);

  @override
  Future<void> generate(ComposeArgs args) async {
    // Default direct generator entrypoint maps to compose-main.
    await composeMain(args);
  }

  Future<void> composeMain(ComposeArgs args) async {
    _logComposeStart(mode: 'compose-main', args: args);
    await mainService.generate((
      app: args.app,
      module: args.module,
      feature: args.feature,
      slice: args.slice,
      targetPage: args.targetPage,
      pageMode: ComposePageMode.main,
      strict: args.strict,
    ));
    _logComposeDone();
  }

  Future<void> composeForm(ComposeArgs args) async {
    _logComposeStart(mode: 'compose-form', args: args);
    await mainService.generate((
      app: args.app,
      module: args.module,
      feature: args.feature,
      slice: args.slice,
      targetPage: args.targetPage,
      pageMode: ComposePageMode.form,
      strict: args.strict,
    ));
    _logComposeDone();
  }

  Future<void> composeFormDialog(ComposeArgs args) async {
    _logComposeStart(mode: 'compose-form-dialog', args: args);
    await mainService.generate((
      app: args.app,
      module: args.module,
      feature: args.feature,
      slice: args.slice,
      targetPage: args.targetPage,
      pageMode: ComposePageMode.formDialog,
      strict: args.strict,
    ));
    _logComposeDone();
  }

  Future<void> composePag(ComposeArgs args) async {
    _logComposeStart(mode: 'compose-pag', args: args);
    await pagService.generate(args);
    _logComposeDone();
  }

  Future<void> composePmi(ComposeArgs args) async {
    _logComposeStart(mode: 'compose-pmi', args: args);
    await pmiService.generate(args);
    _logComposeDone();
  }

  Future<void> composeAction(ComposeArgs args) async {
    _logComposeStart(mode: 'compose-action', args: args);
    await pmiService.generate(args, actionMode: true);
    _logComposeDone();
  }

  Future<void> composeSec(ComposeArgs args) async {
    _logComposeStart(mode: 'compose-sec', args: args);
    await pmiService.generate(args, sectionMode: true);
    _logComposeDone();
  }

  void _logComposeStart({required String mode, required ComposeArgs args}) {
    logger.log('Building and composing...');
    logger.log('· Mode: $mode');
    logger.log(
      '· Target: app=${args.app}, module=${args.module}, feature=${args.feature}, slice=${args.slice}, page=${args.targetPage}',
    );
  }

  void _logComposeDone() {
    if (exitCode == 0) {
      logger.log('✓ Compose pipeline completed.');
    }
  }
}
