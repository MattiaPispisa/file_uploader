part of 'file_upload_controller.dart';

class _RestorableChunkedFileUploadController extends FileUploadController {
  _RestorableChunkedFileUploadController({
    required RestorableChunkedFileUploadHandler handler,
    FileUploaderLogger? logger,
    List<FileTransformer> transformers = const [],
  })  : _handler = handler,
        _logger = logger,
        _transformers = transformers,
        super._();

  final RestorableChunkedFileUploadHandler _handler;
  final FileUploaderLogger? _logger;
  final List<FileTransformer> _transformers;
  FileUploadPresentationResponse? _presentationResponse;

  @override
  Future<FileUploadResult> upload({
    ProgressCallback? onProgress,
    ProgressCallback? onTransformationProgress,
  }) async {
    _ensureNotUploaded();

    final fileToUpload = await _applyTransformers(
      handler: _handler,
      transformers: _transformers,
      logger: _logger,
      onTransformationProgress: onTransformationProgress,
    );

    _logger?.info('uploading file ${fileToUpload.path}');

    try {
      _presentationResponse = await _handler.present(fileToUpload);
    } catch (error, stackTrace) {
      _logger?.error(
        'error presenting file ${fileToUpload.path}',
        error,
        stackTrace,
      );
      rethrow;
    }

    final size = await fileToUpload.length();
    var sizeSent = 0;

    await _chunksIterator(
      fileToUpload,
      chunkSize: _handler.chunkSize,
      chunkCallback: (chunk, i) async {
        _logger?.info('uploading chunk $i of ${fileToUpload.path}');

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
            'error uploading chunk $i of ${fileToUpload.path}',
            error,
            stackTrace,
          );
          rethrow;
        }
      },
    );

    _setUploaded();
    onProgress?.call(size, size);

    _logger?.info('file uploaded ${fileToUpload.path}');

    final result = FileUploadResult(
      file: _handler.file,
      id: _presentationResponse!.id,
    );

    await _cleanupTransformedFiles();

    return result;
  }

  @override
  Future<FileUploadResult> retry({
    ProgressCallback? onProgress,
    ProgressCallback? onTransformationProgress,
  }) async {
    _ensureNotUploaded();

    final fileToUpload = await _applyTransformers(
      handler: _handler,
      transformers: _transformers,
      logger: _logger,
      onTransformationProgress: onTransformationProgress,
    );

    _logger?.info('retry uploading file ${fileToUpload.path}');

    try {
      // retrieve the presentation if was successfully fired
      _presentationResponse ??= await _handler.present(fileToUpload);
    } catch (error, stackTrace) {
      _logger?.error(
        'error retrieving presentation for file ${fileToUpload.path}',
        error,
        stackTrace,
      );
      rethrow;
    }

    final status = await _handler.status(_presentationResponse!);

    final size = await fileToUpload.length();
    var sizeSent = math.max(status.nextChunkOffset - 1, 0) *
        (_handler.chunkSize ?? defaultChunkSize);

    _logger?.info(
      'retry uploading file ${fileToUpload.path}'
      ' from offset: ${status.nextChunkOffset}',
    );

    // use [status.nextChunkOffset] to skip already uploaded chunks
    await _chunksIterator(
      fileToUpload,
      chunkSize: _handler.chunkSize,
      startFrom: status.nextChunkOffset,
      chunkCallback: (chunk, i) async {
        _logger?.info('retry uploading chunk $i of ${fileToUpload.path}');

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
            'error retry uploading chunk $i of ${fileToUpload.path}',
            error,
            stackTrace,
          );
          rethrow;
        }
      },
    );

    _setUploaded();
    onProgress?.call(size, size);

    _logger?.info('file upload retry completed ${fileToUpload.path}');

    final result = FileUploadResult(
      file: _handler.file,
      id: _presentationResponse!.id,
    );

    await _cleanupTransformedFiles();

    return result;
  }
}
