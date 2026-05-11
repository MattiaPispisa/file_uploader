import 'package:en_file_uploader/en_file_uploader.dart';

/// base class for file uploader exceptions
///
/// currently exceptions are:
///
/// - [UnexpectedHandlerException]
/// - [FileAlreadyUploadedException]
abstract class FileUploaderException implements Exception {}

/// {@template unexpected_handler_exception}
/// unexpected handler exception
///
/// [FileUploadController] is not able
/// to handle the [IFileUploadHandler] passed.
/// {@endtemplate}
class UnexpectedHandlerException implements FileUploaderException {
  /// {@macro unexpected_handler_exception}
  const UnexpectedHandlerException({
    required this.handler,
  }) : super();

  /// unrecognized file upload handler
  final IFileUploadHandler handler;

  @override
  String toString() {
    return 'unexpected handler ${handler.runtimeType}';
  }
}

/// {@template file_already_uploaded_exception}
/// file already uploaded exception
///
/// a file that has been uploaded cannot be uploaded again.
/// {@endtemplate}
class FileAlreadyUploadedException implements FileUploaderException {
  /// {@macro file_already_uploaded_exception}
  const FileAlreadyUploadedException() : super();

  @override
  String toString() {
    return 'file already uploaded';
  }
}
