import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;

/// instance of [utils.InMemoryBackend]
final backend = utils.InMemoryBackend();

void main() async {
  backend.clear();

  var sampleFile = utils.createFile(fileName: 'test1');
  var handler = ExampleRestorableChunkedFileUploadHandler(
    file: sampleFile,
    chunkSize: 500,
  );
  var controller = FileUploadController(handler);
  await controller.upload();

  sampleFile = utils.createFile(fileName: 'test2');
  handler = ExampleRestorableChunkedFileUploadHandler(
    file: sampleFile,
    chunkSize: 1000,
  );
  controller = FileUploadController(handler);
  await controller.upload();

  // print(backend);
}

/// An example implementation of a [RestorableChunkedFileUploadHandler]
/// handler that sends data to an [utils.InMemoryBackend]
class ExampleRestorableChunkedFileUploadHandler
    extends RestorableChunkedFileUploadHandler {
  /// constructor
  ExampleRestorableChunkedFileUploadHandler({
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
