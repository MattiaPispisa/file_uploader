part of 'file_upload_controller.dart';

class _RestorableChunkedFileUploadController implements FileUploadController {
  _RestorableChunkedFileUploadController({
    required this.handler,
    this.logger,
  });

  final RestorableChunkedFileUploadHandler handler;
  final FileUploaderLogger? logger;
  FileUploadPresentationResponse? _presentationResponse;

  @override
  Future<void> upload({
    ProgressCallback? onProgress,
  }) async {
    logger?.info('uploading file ${handler.file.path}');

    _presentationResponse = await handler.present();
    final size = await handler.file.length();
    var count = 0;

    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      chunkCallback: (chunk, i) {
        logger?.info('uploading chunk $i');

        return handler.uploadChunk(
          _presentationResponse!,
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

    // retrieve the presentation if was successfully fired
    _presentationResponse ??= await handler.present();
    final status = await handler.status(_presentationResponse!);

    final size = await handler.file.length();
    final count = math.max(status.nextChunkOffset - 1, 0) *
        (handler.chunkSize ?? defaultChunkSize);

    // use [status.nextChunkOffset] to skip already uploaded chunks
    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      startFrom: status.nextChunkOffset,
      chunkCallback: (chunk, i) {
        logger?.info('uploading chunk $i');

        return handler.uploadChunk(
          _presentationResponse!,
          chunk,
          onProgress: (chunkCount, _) {
            onProgress?.call(count, size);
          },
        );
      },
    );

    return;
  }
}
