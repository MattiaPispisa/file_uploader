part of 'file_upload_controller.dart';

class _ChunkedFileUploadController extends FileUploadController {
  _ChunkedFileUploadController({
    required ChunkedFileUploadHandler handler,
    FileUploaderLogger? logger,
    List<FileTransformer> transformers = const [],
  })  : _handler = handler,
        super._(transformers, logger);

  @override
  final ChunkedFileUploadHandler _handler;

  @override
  Future<FileUploadResult> upload({
    ProgressCallback? onProgress,
    TransformationProgressCallback? onTransformationProgress,
  }) async {
    _ensureNotUploaded();

    final fileToUpload = await _applyTransformers(
      handler: _handler,
      onTransformationProgress: onTransformationProgress,
    );

    _logger?.info('uploading file ${fileToUpload.path}');

    final size = await fileToUpload.length();
    var sizeSent = 0;

    await _chunksIterator(
      fileToUpload,
      chunkSize: _handler.chunkSize,
      chunkCallback: (chunk, i) async {
        _logger?.info('uploading chunk $i of ${fileToUpload.path}');

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
      file: _handler.originalFile,
      id: _generateUniqueId(),
    );

    await _cleanupTransformedFiles();

    return result;
  }

  @override
  Future<FileUploadResult> retry({
    ProgressCallback? onProgress,
    TransformationProgressCallback? onTransformationProgress,
  }) async {
    _ensureNotUploaded();

    final fileToUpload = await _applyTransformers(
      handler: _handler,
      onTransformationProgress: onTransformationProgress,
    );

    _logger?.info('retry uploading file ${fileToUpload.path}');

    final size = await fileToUpload.length();
    var sizeSent = 0;

    await _chunksIterator(
      fileToUpload,
      chunkSize: _handler.chunkSize,
      chunkCallback: (chunk, i) async {
        _logger?.info('retry uploading chunk $i of ${fileToUpload.path}');

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
      file: _handler.originalFile,
      id: _generateUniqueId(),
    );

    await _cleanupTransformedFiles();

    return result;
  }
}
