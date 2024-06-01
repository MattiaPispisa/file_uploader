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
    _presentationResponse = await handler.present();
    final size = await handler.file.length();
    var count = 0;

    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      chunkCallback: (chunk, i) {
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
    _presentationResponse ??= await handler.present();
    final status = await handler.status(_presentationResponse!);

    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      startFrom: status.nextChunkOffset,
      chunkCallback: (chunk, i) {
        return handler.uploadChunk(_presentationResponse!, chunk);
      },
    );

    return;
  }
}
