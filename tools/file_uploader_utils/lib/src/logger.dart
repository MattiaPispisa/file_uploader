import 'package:en_file_uploader/en_file_uploader.dart';

class PrintLogger implements FileUploaderLogger {
  @override
  void error(String message, error, stackTrace) {
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
