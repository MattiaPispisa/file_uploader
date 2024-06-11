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

    await _handler.upload(onProgress: onProgress);

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

    await _handler.upload();

    _setUploaded();
    onProgress?.call(size, size);

    return FileUploadResult(
      file: _handler.file,
      id: _generateUniqueId(),
    );
  }
}
