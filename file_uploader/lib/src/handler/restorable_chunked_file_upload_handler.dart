import 'package:file_uploader/src/entity/entity.dart';
import 'package:file_uploader/src/handler/i_file_upload_handler.dart';

abstract class RestorableChunkedFileUploadHandler extends IFileUploadHandler {
  const RestorableChunkedFileUploadHandler({
    required super.file,
    this.chunkSize,
  });

  final int? chunkSize;

  Future<FileUploadPresentationResponse> present();
  Future<void> uploadChunk(
    FileUploadPresentationResponse presentation,
    FileChunk chunk, {
    ProgressCallback? onProgress,
  });
  Future<FileUploadStatusResponse> status(
    FileUploadPresentationResponse presentation,
  );
}
