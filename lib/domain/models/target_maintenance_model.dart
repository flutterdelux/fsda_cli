import '../enums/maintenance_type.dart';

class TargetMaintenanceModel {
  final MaintenanceType type;
  final String name;
  final String path;

  TargetMaintenanceModel({
    required this.type,
    required this.name,
    required this.path,
  });
}
