import 'package:args/command_runner.dart';

abstract class BaseCommand extends Command<int> {
  int get successCode => 0;
  int get errorUsage => 64;
  int get errorSystem => 1;

  bool hasOption(String name, {String? abbr}) {
    final args = argResults?.arguments ?? [];
    return args.any((arg) {
      if (arg == '--$name' || arg.startsWith('--$name=')) {
        return true;
      }
      if (abbr != null &&
          (arg == '-$abbr' ||
              (arg.startsWith('-$abbr') && !arg.startsWith('--')))) {
        return true;
      }
      return false;
    });
  }
}
