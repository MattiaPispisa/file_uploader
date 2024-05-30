part of 'file_upload_controller.dart';

class _ChunkedFileUploadController implements FileUploadController {
  const _ChunkedFileUploadController({required this.handler});

  final ChunkedFileUploadHandler handler;

  @override
  Future<void> upload({
    ProgressCallback? onProgress,
    UploadErrorCallback? onError,
  }) async {
    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      chunkCallback: handler.uploadChunk,
    );

    return;
  }

  @override
  Future<void> retry({
    ProgressCallback? onProgress,
    UploadErrorCallback? onError,
  }) async {
    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      chunkCallback: handler.uploadChunk,
    );

    return;
  }
}
