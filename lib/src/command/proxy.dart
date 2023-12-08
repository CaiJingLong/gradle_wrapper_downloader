import 'dart:io';

import 'package:args/args.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:gradle_wrapper/src/command/base.dart';

class ProxyCommand extends DlCommand {
  @override
  String get name => 'proxy';

  @override
  String get description => 'Read http_proxy to download Gradle wrapper.';

  @override
  List<String> get aliases => ['p'];

  @override
  void initialize(ArgParser argParser) {
    super.initialize(argParser);
    argParser.addOption(
      'proxy',
      abbr: 'p',
      help: 'The proxy to download the wrapper to, will override http_proxy.',
    );
  }

  @override
  Uri makeUri(String url) {
    return Uri.parse(url);
  }

  String? configProxy;

  @override
  Future<void> runCommand(ArgResults? argResults) {
    configProxy = argResults!['proxy'] as String?;
    return super.runCommand(argResults);
  }

  String? _getProxy() {
    if (configProxy != null) {
      return configProxy!;
    }
    return Platform.environment['http_proxy'];
  }

  @override
  Dio makeDio() {
    final dio = super.makeDio();
    var proxy = _getProxy();
    if (proxy != null) {
      if (proxy.startsWith('http://')) {
        proxy = proxy.replaceFirst('http://', '');
      }
      if (proxy.startsWith('https://')) {
        proxy = proxy.replaceFirst('https://', '');
      }
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (uri) {
            return 'PROXY $proxy';
          };
          return client;
        },
      );
    }
    return dio;
  }
}
