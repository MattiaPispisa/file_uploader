part of 'file_upload_controller.dart';

class _FileUploadController implements FileUploadController {
  const _FileUploadController({
    required this.handler,
    this.logger,
  });

  final FileUploadHandler handler;
  final FileUploaderLogger? logger;

  @override
  Future<void> upload({
    ProgressCallback? onProgress,
  }) {
    logger?.info('uploading file ${handler.file.path}');
    return handler.upload(onProgress: onProgress);
  }

  @override
  Future<void> retry({
    ProgressCallback? onProgress,
  }) {
    logger?.info('retry file ${handler.file.path}');
    return handler.upload();
  }
}
