part of 'file_upload_controller.dart';

class _FileUploadController extends FileUploadController {
  _FileUploadController({
    required FileUploadHandler handler,
    FileUploaderLogger? logger,
    List<FileTransformer> transformers = const [],
  })  : _handler = handler,
        _logger = logger,
        _transformers = transformers,
        super._();

  final FileUploadHandler _handler;
  final FileUploaderLogger? _logger;
  final List<FileTransformer> _transformers;

  @override
  Future<FileUploadResult> upload({
    ProgressCallback? onProgress,
    TransformationProgressCallback? onTransformationProgress,
  }) async {
    _ensureNotUploaded();

    final fileToUpload = await _applyTransformers(
      handler: _handler,
      transformers: _transformers,
      logger: _logger,
      onTransformationProgress: onTransformationProgress,
    );

    _logger?.info('uploading file ${fileToUpload.path}');
    final size = await fileToUpload.length();

    try {
      await _handler.upload(fileToUpload, onProgress: onProgress);
    } catch (error, stackTrace) {
      _logger?.error(
        'error uploading file ${fileToUpload.path}',
        error,
        stackTrace,
      );
      rethrow;
    }

    _setUploaded();
    onProgress?.call(size, size);

    _logger?.info('file uploaded ${fileToUpload.path}');

    final result = FileUploadResult(
      file: _handler.originalFile,
      id: _generateUniqueId(),
    );

    await _cleanupTransformedFiles(logger: _logger);

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
      transformers: _transformers,
      logger: _logger,
      onTransformationProgress: onTransformationProgress,
    );

    _logger?.info('retry uploading file ${fileToUpload.path}');
    final size = await fileToUpload.length();

    try {
      await _handler.upload(fileToUpload);
    } catch (error, stackTrace) {
      _logger?.error(
        'error retry uploading file ${fileToUpload.path}',
        error,
        stackTrace,
      );
      rethrow;
    }

    _setUploaded();
    onProgress?.call(size, size);

    _logger?.info('file upload retry completed ${fileToUpload.path}');

    final result = FileUploadResult(
      file: _handler.originalFile,
      id: _generateUniqueId(),
    );

    await _cleanupTransformedFiles(logger: _logger);

    return result;
  }
}
