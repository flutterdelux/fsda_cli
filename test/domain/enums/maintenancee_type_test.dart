import 'package:fsda_cli/domain/enums/maintenancee_type.dart';
import 'package:test/test.dart';

void main() {
  group('MaintenanceType Tests', () {
    test('values should have correct string representation', () {
      expect(MaintenanceType.module.value, 'module');
      expect(MaintenanceType.app.value, 'app');
    });
  });
}
