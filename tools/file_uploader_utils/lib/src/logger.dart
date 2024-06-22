// ignore_for_file: avoid_print

import 'package:en_file_uploader/en_file_uploader.dart';

/// A [FileUploaderLogger] implementation that log every message using [print]
class PrintLogger implements FileUploaderLogger {
  @override
  void error(String message, dynamic error, dynamic stackTrace) {
    print(message);
  }

  @override
  void info(String message) {
    print(message);
  }

  @override
  void warning(String message) {
    print(message);
  }
}
