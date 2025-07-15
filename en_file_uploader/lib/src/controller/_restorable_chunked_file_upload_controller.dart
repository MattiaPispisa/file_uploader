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

    try {
      _presentationResponse = await _handler.present();
    } catch (error, stackTrace) {
      _logger?.error(
        'error presenting file ${_handler.file.path}',
        error,
        stackTrace,
      );
      rethrow;
    }

    final size = await _handler.file.length();
    var sizeSent = 0;

    await _chunksIterator(
      _handler.file,
      chunkSize: _handler.chunkSize,
      chunkCallback: (chunk, i) async {
        _logger?.info('uploading chunk $i of ${_handler.file.path}');

        try {
          await _handler.uploadChunk(
            _presentationResponse!,
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
      id: _presentationResponse!.id,
    );
  }

  @override
  Future<FileUploadResult> retry({
    ProgressCallback? onProgress,
  }) async {
    _ensureNotUploaded();
    _logger?.info('retry uploading file ${_handler.file.path}');

    try {
      // retrieve the presentation if was successfully fired
      _presentationResponse ??= await _handler.present();
    } catch (error, stackTrace) {
      _logger?.error(
        'error retrieving presentation for file ${_handler.file.path}',
        error,
        stackTrace,
      );
      rethrow;
    }

    final status = await _handler.status(_presentationResponse!);

    final size = await _handler.file.length();
    var sizeSent = math.max(status.nextChunkOffset - 1, 0) *
        (_handler.chunkSize ?? defaultChunkSize);

    _logger?.info(
      'retry uploading file ${_handler.file.path}'
      ' from offset: ${status.nextChunkOffset}',
    );

    // use [status.nextChunkOffset] to skip already uploaded chunks
    await _chunksIterator(
      _handler.file,
      chunkSize: _handler.chunkSize,
      startFrom: status.nextChunkOffset,
      chunkCallback: (chunk, i) async {
        _logger?.info('retry uploading chunk $i of ${_handler.file.path}');

        try {
          await _handler.uploadChunk(
            _presentationResponse!,
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
      id: _presentationResponse!.id,
    );
  }
}
