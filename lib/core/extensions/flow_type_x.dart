import '../../domain/enums/flow_type.dart';

extension FlowTypeX on FlowType {
  String? get returnType => switch (this) {
    .asynchronous => 'Future',
    .synchronous => null,
    .stream => 'Stream',
  };

  String get resultType => switch (this) {
    .asynchronous => 'AsyncResult',
    .synchronous => 'Result',
    .stream => 'StreamResult',
  };
}
