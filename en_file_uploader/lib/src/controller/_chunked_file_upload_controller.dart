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
    var sizeSent = 0;

    await _chunksIterator(
      _handler.file,
      chunkSize: _handler.chunkSize,
      chunkCallback: (chunk, i) async {
        _logger?.info('uploading chunk $i of ${_handler.file.path}');

        try {
          await _handler.uploadChunk(
            chunk,
            onProgress: (chunkCount, _) {
              onProgress?.call(sizeSent + chunkCount, size);
            },
          );
          // when chunk is complete, add its size to count
          sizeSent += chunk.end - chunk.start;
        } catch (error, stackTrace) {
          _logger?.error(
            'error uploading chunk $i of ${_handler.file.path}',
            error,
            stackTrace,
          );
          rethrow;
        }
      },
    );

    _setUploaded();
    onProgress?.call(size, size);

    _logger?.info('file uploaded ${_handler.file.path}');

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
    _logger?.info('retry uploading file ${_handler.file.path}');

    final size = await _handler.file.length();
    var sizeSent = 0;

    await _chunksIterator(
      _handler.file,
      chunkSize: _handler.chunkSize,
      chunkCallback: (chunk, i) async {
        _logger?.info('retry uploading chunk $i of ${_handler.file.path}');

        try {
          await _handler.uploadChunk(
            chunk,
            onProgress: (chunkCount, _) {
              onProgress?.call(sizeSent + chunkCount, size);
            },
          );
          // when chunk is complete, add its size to count
          sizeSent += chunk.end - chunk.start;
        } catch (error, stackTrace) {
          _logger?.error(
            'error retry uploading chunk $i of ${_handler.file.path}',
            error,
            stackTrace,
          );
          rethrow;
        }
      },
    );

    _setUploaded();
    onProgress?.call(size, size);

    _logger?.info('file upload retry completed ${_handler.file.path}');

    return FileUploadResult(
      file: _handler.file,
      id: _generateUniqueId(),
    );
  }
}
