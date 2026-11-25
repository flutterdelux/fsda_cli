import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/plan_model_x.dart';
import '../../domain/models/plan_model.dart';
import '../../domain/params/workspace_param.dart';
import '../../infrastructure/services/plan_service.dart';
import '../resolvers/app_resolver.dart';
import '../resolvers/feature_resolver.dart';
import '../resolvers/module_resolver.dart';
import '../resolvers/slice_resolver.dart';
import 'wrapper/workspace_guard_command.dart';

class PlanCommand extends WorkspaceGuardCommand {
  final PlanService _planService;

  PlanCommand({
    required PlanService planService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _planService = planService {
    argParser.addOption(
      AppResolverKeys.app,
      abbr: 'a',
      help: 'Target app name for an app compose plan.',
    );
    argParser.addOption(
      ModuleResolverKeys.module,
      abbr: 'm',
      help: 'Target module name for a module or feature plan.',
    );
    argParser.addOption(
      FeatureResolverKeys.feature,
      abbr: 'f',
      help: 'Target feature name for a feature plan (requires -m).',
    );
    argParser.addOption(
      SliceResolverKeys.slice,
      abbr: 's',
      help: 'Target slice name for a slice plan (requires -s).',
    );
    argParser.addFlag(
      'example',
      abbr: 'e',
      negatable: false,
      help: 'Populate the plan template with a ready-to-use CRUD example.',
    );
  }

  @override
  String get name => 'plan';

  @override
  String get description =>
      'Scaffolds a declarative YAML plan file inside .fsda/plans/.';

  @override
  String get invocation =>
      'fsda $name (-m <module> | -m <module> -f <feature> | -a <app>)';

  @override
  Future<int> handle(WorkspaceParam workspace) async {
    final rest = argResults?.rest ?? [];
    if (rest.isNotEmpty) {
      logger.error('Invalid command.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final data = argResults?.toMap() ?? {};

    final isExample = argResults?.flag('example') ?? false;
    final hasApp = hasOption(AppResolverKeys.app, abbr: 'a');
    final hasModule = hasOption(ModuleResolverKeys.module, abbr: 'm');
    final hasFeature = hasOption(FeatureResolverKeys.feature, abbr: 'f');
    final hasSlice = hasOption(SliceResolverKeys.slice, abbr: 's');

    final PlanModel plan;
    try {
      if (hasApp && !hasModule && !hasFeature && !hasSlice) {
        final app = AppResolver.resolve(data: data, workspace: workspace);
        plan = AppPlanModel(app: app);
      } else if (hasModule && !hasFeature && !hasSlice && !hasApp) {
        final module = ModuleResolver.resolve(data: data, workspace: workspace);
        plan = ModulePlanModel(module: module);
      } else if (hasModule && hasFeature && !hasSlice && !hasApp) {
        final module = ModuleResolver.resolve(data: data, workspace: workspace);
        final feature = FeatureResolver.resolve(data: data, module: module);
        plan = FeaturePlanModel(feature: feature);
      } else if (hasModule && hasFeature && hasSlice && !hasApp) {
        final module = ModuleResolver.resolve(data: data, workspace: workspace);
        final feature = FeatureResolver.resolve(data: data, module: module);
        final slice = SliceResolver.resolve(data: data, feature: feature);
        plan = SlicePlanModel(slice: slice);
      } else {
        usageException(
          'Use one of these combinations:\n'
          '  fsda plan -m <module>\n'
          '  fsda plan -m <module> -f <feature>\n'
          '  fsda plan -m <module> -f <feature> -s <slice>\n'
          '  fsda plan -a <app>',
        );
      }
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (await _planService.exists(plan)) {
      logger.error('Plan file already exists at ${plan.planPath}');
      return errorUsage;
    }

    final progress = logger.progress('Scaffolding declarative plan...');

    try {
      final createdPath = await _planService.generate(
        plan: plan,
        isExample: isExample,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Created plan template at $createdPath');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Plan Scaffolding Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to create plan template: $e');
      return errorSystem;
    }
  }
}
