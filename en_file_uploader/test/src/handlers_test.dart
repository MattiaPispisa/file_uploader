import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart';
import 'package:test/test.dart';

void main() {
  group('handlers', () {
    test('should construct handlers correctly', () {
      final file = createFile();
      final fileUploadHandler = ThrowFileUploadHandler(file: file);
      expect(fileUploadHandler.file, file);

      final chunkedFileUploadHandler = ThrowChunkedFileUploadHandler(
        file: file,
        chunkSize: 50,
      );
      expect(chunkedFileUploadHandler.file, file);
      expect(chunkedFileUploadHandler.chunkSize, 50);

      final restorableChunkedFileUploadHandler =
          ThrowRestorableChunkedFileUploadHandler(
        file: file,
        chunkSize: 100,
      );
      expect(restorableChunkedFileUploadHandler.file, file);
      expect(restorableChunkedFileUploadHandler.chunkSize, 100);
    });
  });
}

class ThrowFileUploadHandler extends FileUploadHandler {
  ThrowFileUploadHandler({required super.file});

  @override
  Future<void> upload({ProgressCallback? onProgress}) {
    throw UnimplementedError();
  }
}

class ThrowChunkedFileUploadHandler extends ChunkedFileUploadHandler {
  ThrowChunkedFileUploadHandler({
    required super.file,
    super.chunkSize,
  });

  @override
  Future<void> uploadChunk(
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) {
    throw UnimplementedError();
  }
}

class ThrowRestorableChunkedFileUploadHandler
    extends RestorableChunkedFileUploadHandler {
  ThrowRestorableChunkedFileUploadHandler({
    required super.file,
    super.chunkSize,
  });

  @override
  Future<FileUploadPresentationResponse> present() {
    throw UnimplementedError();
  }

  @override
  Future<FileUploadStatusResponse> status(
    FileUploadPresentationResponse presentation,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> uploadChunk(
    FileUploadPresentationResponse presentation,
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) {
    throw UnimplementedError();
  }
}
