part of 'file_upload_controller.dart';

class _ChunkedFileUploadController extends FileUploadController {
  _ChunkedFileUploadController({
    required ChunkedFileUploadHandler handler,
    FileUploaderLogger? logger,
  })  : _handler = handler,
        _logger = logger,
        super._();

  final ChunkedFileUploadHandler _handler;
  final FileUploaderLogger? _logger;

  @override
  Future<FileUploadResult> upload({
    ProgressCallback? onProgress,
  }) async {
    _ensureNotUploaded();
    _logger?.info('uploading file ${_handler.file.path}');

    final size = await _handler.file.length();
    var count = 0;

    await _chunksIterator(
      _handler.file,
      chunkSize: _handler.chunkSize,
      chunkCallback: (chunk, i) {
        _logger?.info('uploading chunk $i');

        return _handler.uploadChunk(
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
      id: _generateUniqueId(),
    );
  }

  @override
  Future<FileUploadResult> retry({
    ProgressCallback? onProgress,
  }) async {
    _ensureNotUploaded();
    _logger?.info('retry file ${_handler.file.path}');

    final size = await _handler.file.length();
    var count = 0;

    await _chunksIterator(
      _handler.file,
      chunkSize: _handler.chunkSize,
      chunkCallback: (chunk, i) {
        _logger?.info('uploading chunk $i');

        return _handler.uploadChunk(
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
      id: _generateUniqueId(),
    );
  }
}
