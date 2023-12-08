import 'package:args/command_runner.dart';

import 'command/base.dart';
import 'command/ghproxy.dart';

Future<void> runCli(List<String> args) async {
  final CommandRunner<void> runner = CommandRunner<void>(
    'gradle_wrapper_downloader',
    'Download Gradle wrapper for proxy.',
  );

  void addCommand(BaseCommond command) => runner.addCommand(command);

  addCommand(GhproxyCommand());

  await runner.run(args);
}
