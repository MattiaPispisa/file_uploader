import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:en_logger/en_logger.dart';

/// A [FileUploaderLogger] implementation that log
/// every message using [EnLogger]
class FileUploaderEnLoggerHandler extends FileUploaderLogger {
  /// Creates a new [FileUploaderEnLoggerHandler]
  FileUploaderEnLoggerHandler({required EnLogger logger}) : _logger = logger;

  final EnLogger _logger;

  @override
  void error(String message, dynamic error, dynamic stackTrace) {
    _logger.error(
      '$message $error',
      stackTrace: stackTrace is StackTrace ? stackTrace : null,
    );
  }

  @override
  void info(String message) {
    _logger.info(message);
  }

  @override
  void warning(String message) {
    _logger.warning(message);
  }
}

/// [EnLogger] instance for tool package
final logger = EnLogger(
  handlers: [PrinterHandler()],
);

/// [FileUploaderLogger] instance for tool package
final fileUploaderLogger = FileUploaderEnLoggerHandler(logger: logger);
