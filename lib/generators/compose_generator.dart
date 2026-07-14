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
    // Backward-compatible default behavior for legacy compose command usage.
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
