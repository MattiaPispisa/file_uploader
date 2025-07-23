import 'package:en_file_uploader/en_file_uploader.dart';

/// [ChunkedFileUploadHandler] handle the file upload split in chunks
///
/// ## How to use
///
/// Extends this class to implement the upload of a file split in chunks.
///
/// ```dart
/// class MyChunkedFileUploadHandler extends ChunkedFileUploadHandler {
///   MyChunkedFileUploadHandler({required super.file});
/// }
/// ```
///
/// Attach the handler to a [FileUploadController] to upload the file.
///
/// ```dart
/// final controller =
///   FileUploadController(MyChunkedFileUploadHandler(file: file));
/// controller.upload();
/// ```
abstract class ChunkedFileUploadHandler extends IFileUploadHandler {
  /// constructor
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used (can be changed with [setDefaultChunkSize]).
  ///
  /// [file] is the file to upload
  const ChunkedFileUploadHandler({
    required super.file,
    this.chunkSize,
  });

  /// chunk size, if null [defaultChunkSize] is used
  final int? chunkSize;

  /// method to handle the upload of a [FileChunk]
  ///
  /// [chunk] is the chunk to upload.
  ///
  /// [onProgress] is a callback that will be called
  /// with the progress of the upload. The callback
  /// will receive the current progress
  /// and the total size of the file.
  ///
  /// ```dart
  /// controller.uploadChunk(chunk, onProgress: (progress, total) {
  ///   print('Upload progress: $progress of $total');
  /// });
  /// ```
  Future<void> uploadChunk(
    FileChunk chunk, {
    ProgressCallback? onProgress,
  });
}
