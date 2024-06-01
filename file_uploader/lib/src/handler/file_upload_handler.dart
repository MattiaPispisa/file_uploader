import 'package:file_uploader/file_uploader.dart';

abstract class FileUploadHandler extends IFileUploadHandler {
  const FileUploadHandler({
    required super.file,
  });

  Future<void> upload({
    ProgressCallback? onProgress,
  });
}
