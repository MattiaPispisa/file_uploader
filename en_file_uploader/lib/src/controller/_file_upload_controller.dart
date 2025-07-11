part of 'file_upload_controller.dart';

class _FileUploadController extends FileUploadController {
  _FileUploadController({
    required FileUploadHandler handler,
    FileUploaderLogger? logger,
  })  : _handler = handler,
        _logger = logger,
        super._();

  final FileUploadHandler _handler;
  final FileUploaderLogger? _logger;

  @override
  Future<FileUploadResult> upload({
    ProgressCallback? onProgress,
  }) async {
    _ensureNotUploaded();
    _logger?.info('uploading file ${_handler.file.path}');
    final size = await _handler.file.length();

    try {
      await _handler.upload(onProgress: onProgress);
    } catch (error, stackTrace) {
      _logger?.error(
        'error uploading file ${_handler.file.path}',
        error,
        stackTrace,
      );
      rethrow;
    }

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

    try {
      await _handler.upload();
    } catch (error, stackTrace) {
      _logger?.error(
        'error retry uploading file ${_handler.file.path}',
        error,
        stackTrace,
      );
      rethrow;
    }

    _setUploaded();
    onProgress?.call(size, size);

    _logger?.info('file upload retry completed ${_handler.file.path}');

    return FileUploadResult(
      file: _handler.file,
      id: _generateUniqueId(),
    );
  }
}
