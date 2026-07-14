import 'package:get_it/get_it.dart';

import 'core_di.dart';
import 'external_di.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  await externalDI();
  await coreDI();
  await sl.allReady();

  // Modules DI
}
