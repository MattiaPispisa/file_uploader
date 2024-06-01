import 'package:file_uploader/src/entity/entity.dart';
import 'package:file_uploader/src/handler/i_file_upload_handler.dart';

abstract class ChunkedFileUploadHandler extends IFileUploadHandler {
  const ChunkedFileUploadHandler({
    required super.file,
    this.chunkSize,
  });

  final int? chunkSize;

  Future<void> uploadChunk(
    FileChunk chunk, {
    ProgressCallback? onProgress,
  });
}
