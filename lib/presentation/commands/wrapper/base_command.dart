import 'package:args/command_runner.dart';

abstract class BaseCommand extends Command {
  int get successCode => 0;
  int get errorUsage => 64;
  int get errorSystem => 1;
}
