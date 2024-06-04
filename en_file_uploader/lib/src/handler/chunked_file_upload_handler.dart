import 'package:en_file_uploader/en_file_uploader.dart';

/// [ChunkedFileUploadHandler] handle the file upload split in chunks
abstract class ChunkedFileUploadHandler extends IFileUploadHandler {
  /// constructor
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
  const ChunkedFileUploadHandler({
    required super.file,
    this.chunkSize,
  });

  /// chunk size, if null [defaultChunkSize] is used
  final int? chunkSize;

  /// method to handle the upload of a [FileChunk]
  Future<void> uploadChunk(
    FileChunk chunk, {
    ProgressCallback? onProgress,
  });
}
