part of 'file_upload_controller.dart';

class _FileUploadController implements FileUploadController {
  const _FileUploadController({required this.handler});

  final FileUploadHandler handler;

  @override
  Future<void> upload({
    ProgressCallback? onProgress,
    UploadErrorCallback? onError,
  }) {
    return handler.upload();
  }

  @override
  Future<void> retry({
    ProgressCallback? onProgress,
    UploadErrorCallback? onError,
  }) {
    return handler.upload();
  }
}
