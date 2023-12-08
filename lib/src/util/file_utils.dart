import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:path/path.dart';

class FileUtils {
  static String hashName(String uri) {
    try {
      var messageDigest = crypto.md5;
      var bytes = utf8.encode(uri);
      var digest = messageDigest.convert(bytes);

      final signBytes = digest.bytes;

      final sb = StringBuffer();
      for (var i = 0; i < signBytes.length; i++) {
        final value = signBytes[i];
        final hex = value.toRadixString(16).padLeft(2, '0');
        sb.write(hex);
      }

      final hash = sb.toString();
      final bigInt = BigInt.parse(hash, radix: 16);

      return bigInt.toRadixString(36);
    } catch (error) {
      throw Exception("Hash error: $error");
    }
  }

  static String gradleHome() {
    // read env GRADLE_USER_HOME
    final home = Platform.environment['GRADLE_USER_HOME'];
    if (home != null) {
      return home;
    }
    return join(homePath(), '.gradle');
  }

  static String homePath() {
    String homeDir;

    if (Platform.isWindows) {
      homeDir = Platform.environment['USERPROFILE']!;
    } else {
      homeDir = Platform.environment['HOME']!;
    }

    return homeDir;
  }

  static String getDistZipPath(String uri) {
    // /Volumes/SanDisk_2T/mirrors/gradle/wrapper/dists/gradle-6.7-all/cuy9mc7upwgwgeb72wkcrupxe
    final home = gradleHome();
    final name = Uri.parse(uri).pathSegments.last;
    // final regex = RegExp(r'gradle-(\d+\.\d+)-(all|bin|src)\.zip');
    final notExtName = name.replaceAll('.zip', '');

    // final version = regex.firstMatch(name)!.group(1)!;
    // final type = regex.firstMatch(name)!.group(2)!;

    final dstPath = join(
      home,
      'wrapper',
      'dists',
      notExtName,
      hashName(uri),
      name,
    );

    return dstPath;
  }

  static String formatFileLength(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
    }
  }
}
