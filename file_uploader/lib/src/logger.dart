/// an abstract logger used inside the library to report
/// info, warning and errors
abstract class FileUploaderLogger {
  /// info [message]
  void info(String message);

  /// warning [message]
  void warning(String message);

  /// error [message].
  ///
  /// include [error] and [stackTrace]
  void error(String message, dynamic error, dynamic stackTrace);
}
