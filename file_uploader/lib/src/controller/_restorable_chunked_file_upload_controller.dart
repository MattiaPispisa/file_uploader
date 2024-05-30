part of 'file_upload_controller.dart';

class _RestorableChunkedFileUploadController implements FileUploadController {
  _RestorableChunkedFileUploadController({required this.handler});

  final RestorableChunkedFileUploadHandler handler;
  FileUploadPresentationResponse? _presentationResponse;

  @override
  Future<void> upload({
    ProgressCallback? onProgress,
    UploadErrorCallback? onError,
  }) async {
    _presentationResponse = await handler.present();

    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      chunkCallback: (chunk) =>
          handler.uploadChunk(_presentationResponse!, chunk),
    );

    return;
  }

  @override
  Future<void> retry({
    ProgressCallback? onProgress,
    UploadErrorCallback? onError,
  }) async {
    _presentationResponse ??= await handler.present();
    final status = await handler.status(_presentationResponse!);

    await _chunksIterator(
      handler.file,
      chunkSize: handler.chunkSize,
      startFrom: status.nextChunkOffset,
      chunkCallback: (chunk) =>
          handler.uploadChunk(_presentationResponse!, chunk),
    );

    return;
  }
}
