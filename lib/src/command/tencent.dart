import 'package:gradle_wrapper/src/command/base.dart';

class TencentProxyCommand extends DlCommand {
  @override
  String get description =>
      'Use https://mirrors.cloud.tencent.com/gradle/ to proxy download gradle wrapper.';

  @override
  Uri makeUri(String url) {
    final name = Uri.parse(url).pathSegments.last;
    return Uri.parse('https://mirrors.cloud.tencent.com/gradle/$name');
  }

  @override
  String get name => 'tencent';

  @override
  List<String> get aliases => ['t'];
}
