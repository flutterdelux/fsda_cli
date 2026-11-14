import '../../../domain/enums/flow_type.dart';
import '../../../domain/params/sequence_param.dart';
import 'repo_body_common_template.dart';
import 'repo_body_stream_template.dart';

abstract final class RepoBodyTemplate {
  static String build(SequenceParam sequence) {
    return switch (sequence.flow) {
      FlowType.stream => RepoBodyStreamTemplate.build(sequence),
      FlowType.asynchronous ||
      FlowType.synchronous => RepoBodyCommonTemplate.build(sequence),
    };
  }
}
