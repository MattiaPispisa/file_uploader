/// an abstract logger used inside the library to report
/// info, warning and errors
///
/// Concrete example:
/// ```dart
/// // It's just an example, not a production-ready version.
/// // Every log is printed
/// class PrinterLogger implements FileUploaderLogger {
///   @override
///   void error(String message, error, stackTrace) {
///     print(error);
///   }
///
///   @override
///   void info(String message) {
///     print(message);
///   }
///
///   @override
///   void warning(String message) {
///     print(message);
///   }
/// }
/// ```
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
