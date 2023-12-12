import 'package:args/command_runner.dart';

import 'command/base.dart';
import 'command/ghproxy.dart';
import 'command/proxy.dart';
import 'command/tencent.dart';

Future<void> runCli(List<String> args) async {
  final CommandRunner<void> runner = CommandRunner<void>(
    'gradle_wrapper_downloader',
    'Download Gradle wrapper for proxy.',
  );

  void addCommand(BaseCommond command) => runner.addCommand(command);

  addCommand(GhproxyCommand());
  addCommand(ProxyCommand());
  addCommand(TencentProxyCommand());

  await runner.run(args);
}
