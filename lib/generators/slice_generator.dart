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
import '../services/file_service.dart';
import '../services/logger_service.dart';
import '../services/operation_report_service.dart';
import '../services/slices/slice_checkpoint_weaver_service.dart';
import '../services/slices/slice_manifest_render_service.dart';
import '../services/slices/slice_service.dart';
import '../services/slices/slice_source_normalizer_service.dart';

class SliceGenerator {
  final LoggerService logger;
  final FileService fileService;
  final OperationReportService report;
  late final SliceService _sliceService;

  SliceGenerator({
    required this.logger,
    required this.fileService,
    required this.report,
    SliceService? sliceService,
  }) {
    _sliceService =
        sliceService ??
        SliceService(
          logger: logger,
          fileService: fileService,
          report: report,
          manifestRenderService: const SliceManifestRenderService(),
          sourceNormalizerService: const SliceSourceNormalizerService(),
          checkpointWeaverService: SliceCheckpointWeaverService(logger: logger),
        );
  }

  Future<Map<String, dynamic>> generateSliceM(
    ({String slice, String feature, String module, String method}) args,
  ) {
    return _sliceService.generateVariant(
      operationLabel:
          'fsda slice-m ${args.slice} -> ${args.module}/${args.feature}',
      successVerb: 'Mutation slice',
      sequenceDescription: 'mutation',
      isMutation: true,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      bundle: sliceMBundle,
      strict: false,
    );
  }

  Future<Map<String, dynamic>> generateSliceMp(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String paramName,
      String requestName,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel:
          'fsda slice-mp ${args.slice} -> ${args.module}/${args.feature}',
      successVerb: 'Mutation+Param slice',
      sequenceDescription: 'mutation+param',
      isMutation: true,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      bundle: sliceMpBundle,
      strict: false,
      paramName: args.paramName,
      requestName: args.requestName,
    );
  }

  Future<Map<String, dynamic>> generateSliceMr(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      String dtoName,
      String entityName,
      bool isList,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel:
          'fsda slice-mr ${args.slice} -> ${args.module}/${args.feature}',
      successVerb: 'Mutation+Response slice',
      sequenceDescription: 'mutation+response',
      isMutation: true,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      dtoName: args.dtoName,
      entityName: args.entityName,
      isList: args.isList,
      bundle: sliceMrBundle,
      strict: false,
    );
  }

  Future<Map<String, dynamic>> generateSliceMrp(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      String dtoName,
      String entityName,
      String paramName,
      String requestName,
      bool isList,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel:
          'fsda slice-mrp ${args.slice} -> ${args.module}/${args.feature}',
      successVerb: 'Mutation+Response+Param slice',
      sequenceDescription: 'mutation+response+param',
      isMutation: true,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      dtoName: args.dtoName,
      entityName: args.entityName,
      isList: args.isList,
      bundle: sliceMrpBundle,
      strict: false,
      paramName: args.paramName,
      requestName: args.requestName,
    );
  }

  Future<Map<String, dynamic>> generateSliceR(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      String dtoName,
      String entityName,
      bool isList,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel:
          'fsda slice-r ${args.slice} -> ${args.module}/${args.feature}',
      successVerb: 'Retrieval slice',
      sequenceDescription: 'retrieval',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      dtoName: args.dtoName,
      entityName: args.entityName,
      isList: args.isList,
      bundle: sliceRBundle,
      strict: false,
    );
  }

  Future<Map<String, dynamic>> generateSliceRof(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      String dtoName,
      String entityName,
      bool isList,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel:
          'fsda slice-rof ${args.slice} -> ${args.module}/${args.feature}',
      successVerb: 'Retrieval Offline-First slice',
      sequenceDescription: 'offline-first retrieval',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      dtoName: args.dtoName,
      entityName: args.entityName,
      isList: args.isList,
      bundle: sliceRofBundle,
      strict: false,
    );
  }

  Future<Map<String, dynamic>> generateSliceRp(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      String dtoName,
      String entityName,
      String paramName,
      String requestName,
      bool isList,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel:
          'fsda slice-rp ${args.slice} -> ${args.module}/${args.feature}',
      successVerb: 'Retrieval+Param slice',
      sequenceDescription: 'retrieval+param',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      dtoName: args.dtoName,
      entityName: args.entityName,
      isList: args.isList,
      bundle: sliceRpBundle,
      strict: false,
      paramName: args.paramName,
      requestName: args.requestName,
    );
  }

  Future<Map<String, dynamic>> generateSliceRpag(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      String dtoName,
      String entityName,
      String paramName,
      String requestName,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel:
          'fsda slice-rpag ${args.slice} -> ${args.module}/${args.feature}',
      successVerb: 'Retrieval Pagination slice',
      sequenceDescription: 'retrieval pagination',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      dtoName: args.dtoName,
      entityName: args.entityName,
      isList: true,
      bundle: sliceRpagBundle,
      strict: false,
      paramName: args.paramName,
      requestName: args.requestName,
    );
  }

  Future<Map<String, dynamic>> generateSliceRs(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      String dtoName,
      String entityName,
      bool isList,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel:
          'fsda slice-rs ${args.slice} -> ${args.module}/${args.feature}',
      successVerb: 'Retrieval Stream slice',
      sequenceDescription: 'stream retrieval',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      dtoName: args.dtoName,
      entityName: args.entityName,
      isList: args.isList,
      bundle: sliceRsBundle,
      strict: false,
    );
  }

  Future<Map<String, dynamic>> generateSliceRsp(
    ({
      String slice,
      String feature,
      String module,
      String method,
      String model,
      String dtoName,
      String entityName,
      String paramName,
      String requestName,
      bool isList,
    })
    args,
  ) {
    return _sliceService.generateVariant(
      operationLabel:
          'fsda slice-rsp ${args.slice} -> ${args.module}/${args.feature}',
      successVerb: 'Retrieval Stream+Param slice',
      sequenceDescription: 'stream+param retrieval',
      isMutation: false,
      sliceName: args.slice,
      featureName: args.feature,
      moduleName: args.module,
      methodName: args.method,
      modelName: args.model,
      dtoName: args.dtoName,
      entityName: args.entityName,
      isList: args.isList,
      bundle: sliceRspBundle,
      strict: false,
      paramName: args.paramName,
      requestName: args.requestName,
    );
  }
}
