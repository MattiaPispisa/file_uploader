import 'package:file_uploader/file_uploader.dart';

/// [FileUploadHandler] handle the upload of an entire file
abstract class FileUploadHandler extends IFileUploadHandler {
  /// controller
  const FileUploadHandler({
    required super.file,
  });

  /// Method for uploading the entire file.
  Future<void> upload({
    ProgressCallback? onProgress,
  });
}
