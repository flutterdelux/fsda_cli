import 'package:flutter/material.dart';

import 'app/main_app.dart';
import 'core/di/di.dart';
import 'core/externals/logging_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggingConfig.init();
  await initDI();

  runApp(const MainApp());
}
