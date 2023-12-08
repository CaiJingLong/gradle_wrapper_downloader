import 'dart:io';

final logger = Logger();

class Logger {
  bool showDebug = false;

  void log(String message) {
    print('[INFO] $message');
  }

  void write(String message) {
    stdout.write(message);
  }

  void debug(String message) {
    if (showDebug) {
      print('[DEBUG] $message');
    }
  }
}
