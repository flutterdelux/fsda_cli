import 'module_gate_param.dart';

class FailureParam extends ModuleGateParam {
  // use snake case
  final String name;

  // will use for all arb
  final String message;

  const FailureParam({
    required super.moduleName,
    required super.modulePath,
    required this.name,
    required this.message,
  });
}
