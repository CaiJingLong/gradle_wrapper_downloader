import 'base.dart';

class GhproxyCommand extends DlCommand {
  @override
  String get description =>
      'Use https://mirror.ghproxy.com/ to download Gradle wrapper.';

  static const _prefix = 'https://mirror.ghproxy.com';

  @override
  String get name => 'ghproxy';

  @override
  List<String> get aliases => ['ghp', 'g'];

  @override
  Uri makeUri(String url) {
    return Uri.parse('$_prefix/$url');
  }
}
