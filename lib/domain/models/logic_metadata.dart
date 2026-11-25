import '../enums/state_control.dart';
import 'dependency_metadata.dart';

class LogicMetadata extends DependencyMetadata {
  final StateControl control;
  final String method;
  final List<DependencyParamMetadata> methodParameters;

  const LogicMetadata({
    required super.className,
    required super.parameters,
    required this.control,
    required this.method,
    required this.methodParameters,
  });
}
