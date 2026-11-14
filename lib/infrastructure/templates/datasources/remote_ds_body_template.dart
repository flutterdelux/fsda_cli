import '../../../domain/params/sequence_param.dart';
import 'remote_ds_body_async_template.dart';
import 'remote_ds_body_stream_template.dart';

abstract final class RemoteDsBodyTemplate {
  static String build(SequenceParam sequence) {
    return switch (sequence.flow) {
      .asynchronous => RemoteDsBodyAsyncTemplate.build(sequence),
      .synchronous => throw Exception(
        'Synchronous flow with source remote are not available.',
      ),
      .stream => RemoteDsBodyStreamTemplate.build(sequence),
    };
  }
}
