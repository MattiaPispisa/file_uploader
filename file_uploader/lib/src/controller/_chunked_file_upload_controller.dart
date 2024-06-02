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
    logger?.info('uploading file ${handler.file.path}');

    final size = await handler.file.length();
    var count = 0;

    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      chunkCallback: (chunk, i) {
        logger?.info('uploading chunk $i');

        return handler.uploadChunk(
          chunk,
          onProgress: (chunkCount, _) {
            count += chunkCount;
            onProgress?.call(count, size);
          },
        );
      },
    );

    return;
  }

  @override
  Future<void> retry({
    ProgressCallback? onProgress,
  }) async {
    logger?.info('retry file ${handler.file.path}');

    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      chunkCallback: (chunk, i) {
        logger?.info('uploading chunk $i');

        return handler.uploadChunk(chunk);
      },
    );

    return;
  }
}
