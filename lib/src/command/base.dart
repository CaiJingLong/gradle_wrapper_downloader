import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dio/dio.dart';
import 'package:gradle_wrapper/gradle_wrapper.dart';
import 'package:path/path.dart';
import 'package:props/props.dart';

abstract class BaseCommond extends Command<void> {
  BaseCommond() {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      defaultsTo: false,
      negatable: false,
      help: 'Show extra logging information.',
    );
    initialize(argParser);
  }

  @override
  FutureOr<void>? run() {
    // Implement global options here
    if (argResults!['verbose'] as bool) {
      logger.showDebug = true;
    }

    return runCommand(argResults!);
  }

  Future<void> runCommand(ArgResults argResults);

  void initialize(ArgParser argParser) {}

  void throwException(String message) {
    throw UsageException(message, usage);
  }

  void exitByError(String message) {
    print('[ERROR] $message');
    exit(-1);
  }
}

abstract class DlCommand extends BaseCommond {
  @override
  void initialize(ArgParser argParser) {
    super.initialize(argParser);
    argParser.addOption(
      'dir',
      abbr: 'd',
      defaultsTo: '.',
      help: 'The directory to download the wrapper to.',
    );
    argParser.addFlag(
      'force',
      abbr: 'f',
      defaultsTo: false,
      help: 'Force to download the wrapper, even if it already exists.',
    );
  }

  late bool force;

  @override
  Future<void> runCommand(ArgResults? argResults) async {
    final dir = argResults!['dir'] as String;
    force = argResults['force'] as bool;

    final gradleWrappers =
        Directory(dir).listSync(recursive: true).where((entity) {
      return entity is Directory && entity.path.endsWith('gradle/wrapper');
    }).toList();

    if (gradleWrappers.isEmpty) {
      throwException('No gradle wrapper found in $dir');
    }

    logger.log('Found ${gradleWrappers.length} gradle wrappers: ');
    for (final wrapper in gradleWrappers) {
      logger.log(wrapper.path);
    }

    for (final wrapper in gradleWrappers) {
      await downloadWrapper(wrapper.path);
    }
  }

  Future<String> _convertToGithubUrl(String url) async {
    final uri = Uri.parse(url);
    final dio = Dio();
    try {
      final resp = await dio.headUri(uri,
          options: Options(
            followRedirects: false,
            validateStatus: (status) => true,
          ));

      if (resp.statusCode == 301) {
        final location = resp.headers['location']?.first;
        if (location == null) {
          exitByError('Location not found in response header');
        }
        logger.log('Found the location: $location');
        return location!;
      } else {
        throw Exception('Unexpected status code: ${resp.statusCode}');
      }
    } finally {
      dio.close();
    }
  }

  Future<void> downloadWrapper(String path) async {
    final filePath = join(path, 'gradle-wrapper.properties');
    final text = File(filePath).readAsStringSync();
    final properties = Properties.loadString(text);

    logger.log('Load $filePath to get distributionUrl');

    String? url = properties['distributionUrl'];
    if (url == null) {
      exitByError('distributionUrl not found in $filePath');
    }

    logger.log('Found the distributionUrl: $url');

    url = url?.replaceAll('https\\://', 'https://');
    final zipPath = FileUtils.getDistZipPath(url!);

    if (File(zipPath).existsSync()) {
      if (!force) {
        logger.log('The zip file $zipPath already exists.');
        return;
      } else {
        logger.log(
            'The force option is enabled, so delete the old zip file $zipPath.');

        File(zipPath).deleteSync();
      }
    }

    final githubUrl = await _convertToGithubUrl(url);
    final distUri = makeUri(githubUrl);

    logger.log('Downloading $distUri to $zipPath');

    final dio = Dio();
    try {
      if (!File(zipPath).existsSync()) {
        File(zipPath).parent.createSync(recursive: true);
      }
      await dio.downloadUri(
        distUri,
        zipPath,
        onReceiveProgress: (current, total) {
          final progress = (current / total * 100).toStringAsFixed(0);
          final currentText = FileUtils.formatFileLength(current);
          final totalText = FileUtils.formatFileLength(total);
          logger.write('\rDownloading... $progress%, $currentText/$totalText');
        },
      );
      logger.write('\n');
      logger.log('Downloaded successfully.');
    } finally {
      dio.close();
    }
  }

  Uri makeUri(String url);
}
