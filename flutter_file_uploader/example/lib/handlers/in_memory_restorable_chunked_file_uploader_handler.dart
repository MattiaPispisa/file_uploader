import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:example/utils.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;

/// Copied from [en_file_uploader example](https://pub.dev/packages/en_file_uploader/example)

/// An example implementation of a [RestorableChunkedFileUploadHandler]
/// handler that sends data to an [utils.InMemoryBackend]
class InMemoryRestorableChunkedFileUploadHandler
    extends RestorableChunkedFileUploadHandler {
  /// constructor
  InMemoryRestorableChunkedFileUploadHandler({
    required super.file,
    super.chunkSize,
  });

  @override
  Future<FileUploadPresentationResponse> present() {
    final id = backend.handleIncomingFile();
    return Future.value(FileUploadPresentationResponse(id: id));
  }

  @override
  Future<FileUploadStatusResponse> status(
    FileUploadPresentationResponse presentation,
  ) {
    final offset = backend.nextFileOffset(presentation.id);
    return Future.value(
      FileUploadStatusResponse(nextChunkOffset: offset),
    );
  }

  @override
  Future<void> uploadChunk(
    FileUploadPresentationResponse presentation,
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) async {
    final chunkFile =
        (await chunk.file.readAsBytes()).sublist(chunk.start, chunk.end);

    backend.addChunk(
      presentation.id,
      chunkFile,
    );
    return Future.value();
  }
}
