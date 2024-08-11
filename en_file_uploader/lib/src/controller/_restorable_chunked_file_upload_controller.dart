part of 'file_upload_controller.dart';

class _RestorableChunkedFileUploadController extends FileUploadController {
  _RestorableChunkedFileUploadController({
    required RestorableChunkedFileUploadHandler handler,
    FileUploaderLogger? logger,
  })  : _handler = handler,
        _logger = logger,
        super._();

  final RestorableChunkedFileUploadHandler _handler;
  final FileUploaderLogger? _logger;
  FileUploadPresentationResponse? _presentationResponse;

  @override
  Future<FileUploadResult> upload({
    ProgressCallback? onProgress,
  }) async {
    _ensureNotUploaded();
    _logger?.info('uploading file ${_handler.file.path}');

    _presentationResponse = await _handler.present();
    final size = await _handler.file.length();
    var count = 0;

    await _chunksIterator(
      _handler.file,
      chunkSize: _handler.chunkSize,
      chunkCallback: (chunk, i) {
        _logger?.info('uploading chunk $i');

        return _handler.uploadChunk(
          _presentationResponse!,
          chunk,
          onProgress: (chunkCount, _) {
            count += chunkCount;
            onProgress?.call(count, size);
          },
        );
      },
    );

    _setUploaded();
    onProgress?.call(size, size);

    return FileUploadResult(
      file: _handler.file,
      id: _presentationResponse!.id,
    );
  }

  @override
  Future<FileUploadResult> retry({
    ProgressCallback? onProgress,
  }) async {
    _ensureNotUploaded();
    _logger?.info('retry file ${_handler.file.path}');

    // retrieve the presentation if was successfully fired
    _presentationResponse ??= await _handler.present();
    final status = await _handler.status(_presentationResponse!);

    final size = await _handler.file.length();
    var count = math.max(status.nextChunkOffset - 1, 0) *
        (_handler.chunkSize ?? defaultChunkSize);

    // use [status.nextChunkOffset] to skip already uploaded chunks
    await _chunksIterator(
      _handler.file,
      chunkSize: _handler.chunkSize,
      startFrom: status.nextChunkOffset,
      chunkCallback: (chunk, i) {
        _logger?.info('uploading chunk $i');

        return _handler.uploadChunk(
          _presentationResponse!,
          chunk,
          onProgress: (chunkCount, _) {
            count += chunkCount;
            onProgress?.call(count, size);
          },
        );
      },
    );

    _setUploaded();
    onProgress?.call(size, size);

    return FileUploadResult(
      file: _handler.file,
      id: _presentationResponse!.id,
    );
  }
}
