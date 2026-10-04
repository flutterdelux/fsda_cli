import '../generated/bricks/slice_m_bundle.dart';
import '../generated/bricks/slice_mp_bundle.dart';
import '../generated/bricks/slice_mr_bundle.dart';
import '../generated/bricks/slice_mrp_bundle.dart';
import '../generated/bricks/slice_r_bundle.dart';
import '../generated/bricks/slice_rof_bundle.dart';
import '../generated/bricks/slice_rp_bundle.dart';
import '../generated/bricks/slice_rpag_bundle.dart';
import '../generated/bricks/slice_rs_bundle.dart';
import '../generated/bricks/slice_rsp_bundle.dart';
import '../services/slices/slice_service.dart';
import 'base_generator.dart';

class SliceGenerator extends BaseGenerator<void, Never> {
  late final SliceService _sliceService;

  SliceGenerator({
    required super.logger,
    required super.fileService,
    required super.hookService,
    SliceService? sliceService,
  }) {
    final resolvedFileService = fileService;
    final resolvedHookService = hookService;

    if (resolvedFileService == null || resolvedHookService == null) {
      throw ArgumentError(
        'FileService and HookService are required for slice generation.',
      );
    }

    _sliceService =
        sliceService ??
        SliceService(
          logger: logger,
          fileService: resolvedFileService,
          hookService: resolvedHookService,
        );
  }

  Future<void> generateSliceM(
    ({
      String slice,
      String feature,
      String module,
      String method,
      bool hookDisabled,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel: 'fsda slice-m',
      successVerb: 'Mutation slice',
      sequenceDescription: 'mutation',
      isMutation: true,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      bundle: sliceMBundle,
      strict: false,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<void> generateSliceMp(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String paramPrefix,
      String requestPrefix,
      bool hookDisabled,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel: 'fsda slice-mp',
      successVerb: 'Mutation+Param slice',
      sequenceDescription: 'mutation+param',
      isMutation: true,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      bundle: sliceMpBundle,
      strict: false,
      hookDisabled: args.hookDisabled,
      paramPrefix: args.paramPrefix,
      requestPrefix: args.requestPrefix,
    );
  }

  Future<void> generateSliceMr(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      bool isList,
      bool hookDisabled,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel: 'fsda slice-mr',
      successVerb: 'Mutation+Response slice',
      sequenceDescription: 'mutation+response',
      isMutation: true,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      isList: args.isList,
      bundle: sliceMrBundle,
      strict: false,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<void> generateSliceMrp(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      bool isList,
      String paramPrefix,
      String requestPrefix,
      bool hookDisabled,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel: 'fsda slice-mrp',
      successVerb: 'Mutation+Response+Param slice',
      sequenceDescription: 'mutation+response+param',
      isMutation: true,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      isList: args.isList,
      bundle: sliceMrpBundle,
      strict: false,
      hookDisabled: args.hookDisabled,
      paramPrefix: args.paramPrefix,
      requestPrefix: args.requestPrefix,
    );
  }

  Future<void> generateSliceR(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      bool isList,
      bool hookDisabled,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel: 'fsda slice-r',
      successVerb: 'Retrieval slice',
      sequenceDescription: 'retrieval',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      isList: args.isList,
      bundle: sliceRBundle,
      strict: false,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<void> generateSliceRp(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      bool isList,
      String paramPrefix,
      String requestPrefix,
      bool hookDisabled,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel: 'fsda slice-rp',
      successVerb: 'Retrieval+Param slice',
      sequenceDescription: 'retrieval+param',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      isList: args.isList,
      bundle: sliceRpBundle,
      strict: false,
      hookDisabled: args.hookDisabled,
      paramPrefix: args.paramPrefix,
      requestPrefix: args.requestPrefix,
    );
  }

  Future<void> generateSliceRof(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      bool isList,
      bool hookDisabled,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel: 'fsda slice-rof',
      successVerb: 'Retrieval+ObjectField slice',
      sequenceDescription: 'retrieval+object field',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      isList: args.isList,
      bundle: sliceRofBundle,
      strict: false,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<void> generateSliceRpag(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      String paramPrefix,
      String requestPrefix,
      bool hookDisabled,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel: 'fsda slice-rpag',
      successVerb: 'Retrieval+Pagination slice',
      sequenceDescription: 'retrieval+pagination',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      isList: true,
      bundle: sliceRpagBundle,
      strict: false,
      hookDisabled: args.hookDisabled,
      paramPrefix: args.paramPrefix,
      requestPrefix: args.requestPrefix,
    );
  }

  Future<void> generateSliceRs(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      bool isList,
      bool hookDisabled,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel: 'fsda slice-rs',
      successVerb: 'Retrieval+Stream slice',
      sequenceDescription: 'retrieval+stream',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      isList: args.isList,
      bundle: sliceRsBundle,
      strict: false,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<void> generateSliceRsp(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      bool isList,
      String paramPrefix,
      String requestPrefix,
      bool hookDisabled,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel: 'fsda slice-rsp',
      successVerb: 'Retrieval+Stream+Param slice',
      sequenceDescription: 'retrieval+stream+param',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      isList: args.isList,
      bundle: sliceRspBundle,
      strict: false,
      hookDisabled: args.hookDisabled,
      paramPrefix: args.paramPrefix,
      requestPrefix: args.requestPrefix,
    );
  }

  @override
  Future<void> generate(Never args) {
    throw UnsupportedError(
      'Use dedicated methods for slice generation variants.',
    );
  }
}
