import 'package:mason_logger/mason_logger.dart';

class LoggerService {
  static const _char = (ifnfo: 'ℹ', success: '✔', error: '✗');

  final Logger _logger = Logger();

  Progress progress(String message) {
    return _logger.progress(message);
  }

  void info(String message) {
    _logger.info('${lightBlue.wrap(_char.ifnfo)} $message');
  }

  void success(String message) {
    _logger.info('${green.wrap(_char.success)} $message');
  }

  void error(String message) {
    _logger.err('${red.wrap(_char.error)} $message');
  }

  void log(String s) {
    _logger.info(s);
  }
}
