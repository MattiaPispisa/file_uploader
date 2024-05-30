abstract class FileUploaderLogger {
  void info(String message);
  void warning(String message);
  void error(String message, dynamic error, dynamic stackTrace);
}
