import 'package:en_file_uploader/en_file_uploader.dart';

/// [RestorableChunkedFileUploadHandler] handle the file upload in chunk with
/// the capability to retry the upload from the last chunk sent.
/// Follow the `README.md` to understand how this can be made server side
abstract class RestorableChunkedFileUploadHandler extends IFileUploadHandler {
  /// constructor
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
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

  /// method to handle the upload of a [FileChunk]
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
  Future<FileUploadStatusResponse> status(
    FileUploadPresentationResponse presentation,
  );
}
