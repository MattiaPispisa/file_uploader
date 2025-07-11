import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks/mock_chunked_file_upload_handler.dart';
import 'mocks/mock_file_upload_handler.dart';
import 'mocks/mock_restorable_chunked_file_upload_handler.dart';

// Mock logger to verify logging calls
class MockLogger extends Mock implements FileUploaderLogger {}

// Concrete test handlers that guarantee exceptions reach the right catch blocks
class ThrowingChunkedFileUploadHandler extends ChunkedFileUploadHandler {
  ThrowingChunkedFileUploadHandler({
    required super.file,
    super.chunkSize,
    this.shouldFailOnUpload = false,
    this.shouldFailOnRetry = false,
  });

  final bool shouldFailOnUpload;
  final bool shouldFailOnRetry;
  bool _isRetry = false;

  @override
  Future<void> uploadChunk(FileChunk chunk, {ProgressCallback? onProgress}) async {
    if (shouldFailOnUpload && !_isRetry) {
      throw Exception('Upload chunk failed');
    }
    if (shouldFailOnRetry && _isRetry) {
      throw Exception('Retry chunk failed');
    }
  }

  void markAsRetry() => _isRetry = true;
}

class ThrowingRestorableChunkedFileUploadHandler extends RestorableChunkedFileUploadHandler {
  ThrowingRestorableChunkedFileUploadHandler({
    required super.file,
    super.chunkSize,
    this.shouldFailOnUpload = false,
    this.shouldFailOnRetry = false,
    this.nextChunkOffset = 0,
  });

  final bool shouldFailOnUpload;
  final bool shouldFailOnRetry;
  final int nextChunkOffset;
  bool _isRetry = false;

  @override
  Future<FileUploadPresentationResponse> present() async {
    return const FileUploadPresentationResponse(id: 'test-id');
  }

  @override
  Future<FileUploadStatusResponse> status(FileUploadPresentationResponse presentation) async {
    return FileUploadStatusResponse(nextChunkOffset: nextChunkOffset);
  }

  @override
  Future<void> uploadChunk(
    FileUploadPresentationResponse presentation,
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) async {
    if (shouldFailOnUpload && !_isRetry) {
      throw Exception('Upload chunk failed');
    }
    if (shouldFailOnRetry && _isRetry) {
      throw Exception('Retry chunk failed');
    }
  }

  void markAsRetry() => _isRetry = true;
}

void main() {
  group('Error Handling and Logging Tests', () {
    late MockLogger mockLogger;

    setUp(() {
      mockLogger = MockLogger();
    });

    group('FileUploadController Error Handling', () {
      test('should log error and rethrow exception on upload failure', () async {
        final file = createFile();
        final exception = Exception('Upload failed');
        
        final handler = MockFileUploadHandlerBuilder(file)
          ..uploadFn = () => throw exception;
        
        final controller = FileUploadController(
          handler.build(),
          logger: mockLogger,
        );

        await expectLater(
          controller.upload(),
          throwsA(equals(exception)),
        );

        verify(() => mockLogger.info('uploading file ${file.path}')).called(1);
        verify(() => mockLogger.error(
          'error uploading file ${file.path}',
          exception,
          any(),
        )).called(1);
      });

      test('should log error and rethrow exception on retry failure', () async {
        final file = createFile();
        final exception = Exception('Retry failed');
        
        final handler = MockFileUploadHandlerBuilder(file)
          ..uploadFn = () => throw exception;
        
        final controller = FileUploadController(
          handler.build(),
          logger: mockLogger,
        );

        await expectLater(
          controller.retry(),
          throwsA(equals(exception)),
        );

        verify(() => mockLogger.info('retry uploading file ${file.path}')).called(1);
        verify(() => mockLogger.error(
          'error retry uploading file ${file.path}',
          exception,
          any(),
        )).called(1);
      });
    });

    group('ChunkedFileUploadController Error Handling', () {
      test('should log error and rethrow exception on chunk upload failure', () async {
        final file = createFile(length: 2048);
        final exception = Exception('Chunk upload failed');
        
        final handler = MockChunkedFileUploadHandlerBuilder(file)
          ..chunkSize = 1024
          ..chunkFn = () => throw exception;
        
        final controller = FileUploadController(
          handler.build(),
          logger: mockLogger,
        );

        await expectLater(
          controller.upload(),
          throwsA(equals(exception)),
        );

        verify(() => mockLogger.info('uploading file ${file.path}')).called(1);
        verify(() => mockLogger.info('uploading chunk 0 of ${file.path}')).called(1);
        verify(() => mockLogger.error(
          'error uploading chunk 0 of ${file.path}',
          exception,
          any(),
        )).called(1);
      });

      test('should log error and rethrow exception on chunk retry failure', () async {
        final file = createFile(length: 2048);
        final exception = Exception('Chunk retry failed');
        
        final handler = MockChunkedFileUploadHandlerBuilder(file)
          ..chunkSize = 1024
          ..chunkFn = () => throw exception;
        
        final controller = FileUploadController(
          handler.build(),
          logger: mockLogger,
        );

        await expectLater(
          controller.retry(),
          throwsA(equals(exception)),
        );

        verify(() => mockLogger.info('retry uploading file ${file.path}')).called(1);
        verify(() => mockLogger.info('retry uploading chunk 0 of ${file.path}')).called(1);
        verify(() => mockLogger.error(
          'error retry uploading chunk 0 of ${file.path}',
          exception,
          any(),
        )).called(1);
      });
    });

    group('RestorableChunkedFileUploadController Error Handling', () {
      test('should log error and rethrow exception on presentation failure', () async {
        final file = createFile();
        final exception = Exception('Presentation failed');
        
        final handler = MockRestorableChunkedFileUploadHandlerBuilder(file)
          ..presentationFn = () => throw exception;
        
        final controller = FileUploadController(
          handler.build(),
          logger: mockLogger,
        );

        await expectLater(
          controller.upload(),
          throwsA(equals(exception)),
        );

        verify(() => mockLogger.info('uploading file ${file.path}')).called(1);
        verify(() => mockLogger.error(
          'error presenting file ${file.path}',
          exception,
          any(),
        )).called(1);
      });

      test('should log error and rethrow exception on presentation retrieval failure during retry', () async {
        final file = createFile();
        final exception = Exception('Presentation retrieval failed');
        
        final handler = MockRestorableChunkedFileUploadHandlerBuilder(file)
          ..presentationFn = () => throw exception;
        
        final controller = FileUploadController(
          handler.build(),
          logger: mockLogger,
        );

        await expectLater(
          controller.retry(),
          throwsA(equals(exception)),
        );

        verify(() => mockLogger.info('retry uploading file ${file.path}')).called(1);
        verify(() => mockLogger.error(
          'error retrieving presentation for file ${file.path}',
          exception,
          any(),
        )).called(1);
      });

      test('should log error and rethrow exception on chunk upload failure', () async {
        final file = createFile(length: 2048);
        final exception = Exception('Chunk upload failed');
        
        final handler = MockRestorableChunkedFileUploadHandlerBuilder(file)
          ..chunkSize = 1024
          ..chunkFn = () => throw exception;
        
        final controller = FileUploadController(
          handler.build(),
          logger: mockLogger,
        );

        await expectLater(
          controller.upload(),
          throwsA(equals(exception)),
        );

        verify(() => mockLogger.info('uploading file ${file.path}')).called(1);
        verify(() => mockLogger.info('uploading chunk 0 of ${file.path}')).called(1);
        verify(() => mockLogger.error(
          'error uploading chunk 0 of ${file.path}',
          exception,
          any(),
        )).called(1);
      });

      test('should log error and rethrow exception on chunk retry failure', () async {
        final file = createFile(length: 2048);
        final exception = Exception('Chunk retry failed');
        
        final handler = MockRestorableChunkedFileUploadHandlerBuilder(file)
          ..chunkSize = 1024
          ..statusFn = () => Future.value(const FileUploadStatusResponse(nextChunkOffset: 0));
        handler.chunkFn = () => throw exception;
        
        final controller = FileUploadController(
          handler.build(),
          logger: mockLogger,
        );

        await expectLater(
          controller.retry(),
          throwsA(equals(exception)),
        );

        verify(() => mockLogger.info('retry uploading file ${file.path}')).called(1);
        verify(() => mockLogger.info(any(that: contains('retry uploading file ${file.path} from offset:'))));
        verify(() => mockLogger.info('retry uploading chunk 0 of ${file.path}')).called(1);
        verify(() => mockLogger.error(
          'error retry uploading chunk 0 of ${file.path}',
          exception,
          any(),
        )).called(1);
      });
    });

    group('Logger Integration Tests', () {
      test('should work correctly without logger (null logger)', () async {
        final file = createFile();
        final exception = Exception('Upload failed');
        
        final handler = MockFileUploadHandlerBuilder(file)
          ..uploadFn = () => throw exception;
        
        final controller = FileUploadController(
          handler.build(),
          // logger: null (implicitly)
        );

        // Should not crash even without logger
        await expectLater(
          controller.upload(),
          throwsA(equals(exception)),
        );
      });

      test('should log successful operations', () async {
        final file = createFile();
        
        final handler = MockFileUploadHandlerBuilder(file);
        
        final controller = FileUploadController(
          handler.build(),
          logger: mockLogger,
        );

        await controller.upload();

        verify(() => mockLogger.info('uploading file ${file.path}')).called(1);
        verify(() => mockLogger.info('file uploaded ${file.path}')).called(1);
      });
    });
  });
} 