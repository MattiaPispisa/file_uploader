part of 'file_upload_controller.dart';

class _ChunkedFileUploadController implements FileUploadController {
  const _ChunkedFileUploadController({
    required this.handler,
    this.logger,
  });

  final ChunkedFileUploadHandler handler;
  final FileUploaderLogger? logger;

  @override
  Future<void> upload({
    ProgressCallback? onProgress,
  }) async {
    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      chunkCallback: (chunk, i) {
        return handler.uploadChunk(chunk);
      },
    );

    return;
  }

  @override
  Future<void> retry({
    ProgressCallback? onProgress,
  }) async {
    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      chunkCallback: (chunk, i) {
        return handler.uploadChunk(chunk);
      },
    );

    return;
  }
}
