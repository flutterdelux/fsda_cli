import 'package:app_core/app_core.dart';
import 'package:logging/logging.dart';

class LoggingImpl implements AppLogger {
  final Logger _logger;

  LoggingImpl({required Logger logger}) : _logger = logger;

  @override
  void info(String message) {
    _logger.info(message);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.warning(message, error, stackTrace);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.severe(message, error, stackTrace);
  }
}
