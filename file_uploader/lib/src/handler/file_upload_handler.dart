import 'package:file_uploader/src/handler/i_file_upload_handler.dart';

abstract class FileUploadHandler extends IFileUploadHandler {
  const FileUploadHandler({
    required super.file,
  });

  Future<void> upload();
}
