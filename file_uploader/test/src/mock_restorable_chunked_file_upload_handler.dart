import 'package:file_uploader/file_uploader.dart';

class MockRestorableChunkedFileUploadHandler
    extends RestorableChunkedFileUploadHandler {
  MockRestorableChunkedFileUploadHandler({
    required super.file,
    this.presentationFn,
    this.statusFn,
    this.chunkFn,
    super.chunkSize,
  });

  var _presentationFnCount = 0;
  var _statusCount = 0;
  var _chunkCount = 0;

  int get presentationCount => _presentationFnCount;
  int get statusCount => _statusCount;
  int get chunkCount => _chunkCount;

  int get total => presentationCount + statusCount + chunkCount;

  final Future<FileUploadPresentationResponse> Function()? presentationFn;
  final Future<FileUploadStatusResponse> Function(
    FileUploadPresentationResponse presentation,
  )? statusFn;
  final Future<void> Function(
    FileUploadPresentationResponse presentation,
    FileChunk chunk,
  )? chunkFn;

  @override
  Future<FileUploadPresentationResponse> present() async {
    final result = await (presentationFn?.call() ??
        Future.value(const FileUploadPresentationResponse(id: 'id')));
    _presentationFnCount++;
    return result;
  }

  @override
  Future<FileUploadStatusResponse> status(
    FileUploadPresentationResponse presentation,
  ) async {
    final result = await (statusFn?.call(presentation) ??
        Future.value(const FileUploadStatusResponse(nextChunkOffset: 1)));
    _statusCount++;
    return result;
  }

  @override
  Future<void> uploadChunk(
    FileUploadPresentationResponse presentation,
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) async {
    final result =
        await (chunkFn?.call(presentation, chunk) ?? Future.value(true));
    _chunkCount++;
    return result;
  }
}
