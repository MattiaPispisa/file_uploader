import 'package:en_file_uploader/en_file_uploader.dart';

/// [RestorableChunkedFileUploadHandler] handle the file upload in chunk with
/// the capability to retry the upload from the last chunk sent.
/// Follow the [README.md](https://pub.dev/packages/en_file_uploader#support-restorable-chunked-file-upload) to understand how this can be supported by the server side.
///
/// ## How to use
///
/// Extends this class to implement the upload
/// of a file split in chunks with the capability
/// to retry the upload from the last chunk sent.
///
/// ```dart
/// class MyRestorableChunkedFileUploadHandler
///   extends RestorableChunkedFileUploadHandler {
///   MyRestorableChunkedFileUploadHandler({required super.file});
/// }
/// ```
///
/// Attach the handler to a [FileUploadController] to upload the file.
///
/// ```dart
/// final controller =
///   FileUploadController(MyRestorableChunkedFileUploadHandler(file: file));
/// controller.upload();
/// ```
abstract class RestorableChunkedFileUploadHandler extends IFileUploadHandler {
  /// constructor
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used (can be changed with [setDefaultChunkSize]).
  ///
  /// [file] is the file to upload
  const RestorableChunkedFileUploadHandler({
    required super.file,
    this.chunkSize,
  });

  /// chunk size, if null [defaultChunkSize] is used
  final int? chunkSize;

  /// the method to present the file; before uploading the chunks, the file
  /// is presented and needs [FileUploadPresentationResponse].
  ///
  /// [FileUploadPresentationResponse.id] will be used as a reference
  /// for chunk uploads.
  Future<FileUploadPresentationResponse> present();

  /// method to handle the upload of a [FileChunk].
  ///
  /// [presentation] is the response of the [present] method.
  ///
  /// [chunk] is the chunk to upload.
  ///
  /// [onProgress] is a callback that will be called
  /// with the progress of the upload. The callback
  /// will receive the current progress
  /// and the total size of the file.
  ///
  /// ```dart
  /// controller.uploadChunk(
  ///   presentation,
  ///   chunk,
  ///   onProgress: (progress, total) {
  ///   print('Upload progress: $progress of $total');
  /// });
  /// ```
  Future<void> uploadChunk(
    FileUploadPresentationResponse presentation,
    FileChunk chunk, {
    ProgressCallback? onProgress,
  });

  /// the method that, given the presentation id,
  /// allows requesting the file's state.
  ///
  /// The file's state will return [FileUploadStatusResponse].
  /// This is needed to support retrying from the last unsent chunk.
  ///
  /// [presentation] is the response of the [present] method.
  ///
  /// ```dart
  /// controller.retry(); // under the hood status is called and the upload is retried from the last unsent chunk
  /// ```
  Future<FileUploadStatusResponse> status(
    FileUploadPresentationResponse presentation,
  );
}
