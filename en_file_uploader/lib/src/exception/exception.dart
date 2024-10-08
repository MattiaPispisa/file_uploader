import 'package:en_file_uploader/en_file_uploader.dart';

/// base class for file uploader exceptions
abstract class FileUploaderException implements Exception {}

/// unexpected handler exception
class UnexpectedHandlerException implements FileUploaderException {
  /// unexpected handler exception
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

/// file already uploaded exception
class FileAlreadyUploadedException implements FileUploaderException {
  /// file already uploaded exception
  const FileAlreadyUploadedException() : super();

  @override
  String toString() {
    return 'file already uploaded';
  }
}
