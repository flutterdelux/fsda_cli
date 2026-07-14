import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

abstract final class LoggingConfig {
  static void init() {
    Logger.root.level = kDebugMode ? Level.INFO : Level.WARNING;
    Logger.root.onRecord.listen((record) {
      if (record.loggerName.contains('supabase')) return;
      if (kDebugMode) {
        log(
          '[${record.level.name}] ${record.message}',
          name: record.loggerName,
        );
        if (record.level == Level.SEVERE) {
          log(record.error.toString(), name: record.loggerName);
        }
      }
    });
  }
}
