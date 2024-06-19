import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:test/test.dart';
import 'mock_restorable_chunked_file_upload_handler.dart';
import 'robot.dart';

void main() {
  group('configuration', () {
    test('should set default chunk size', () async {
      const size = 1027;
      setDefaultChunkSize(size);

      expect(defaultChunkSize, size);

      late MockRestorableChunkedFileUploadHandler handler;

      final r = Robot()
        ..createFile(length: size + 100)
        ..createController((file) {
          return handler = MockRestorableChunkedFileUploadHandler(
            file: file,
          );
        });

      await r.expectUpload();
      expect(handler.chunkCount, 2);
    });
  });
  group(
    'file_uploader',
    () {
      test('should split in chunk', () async {
        const size = 1024 * 1027;
        late MockRestorableChunkedFileUploadHandler handler;

        final r = Robot()
          ..createFile(length: size)
          ..createController((file) {
            return handler = MockRestorableChunkedFileUploadHandler(
              file: file,
              chunkSize: size ~/ 3,
            );
          });

        await r.expectUpload();
        expect(handler.chunkCount, 4);
      });

      test('should stop on upload, continue in retry', () async {
        const size = 1024 * 1027;
        late MockRestorableChunkedFileUploadHandler handler;

        final r = Robot()
          ..createFile(length: size)
          ..createController((file) {
            return handler = MockRestorableChunkedFileUploadHandler(
              file: file,
              chunkSize: size ~/ 3,
              chunkFn: (presentation, chunk) {
                if (chunk.start >= size ~/ 3 * 2) {
                  throw Exception('something went wrong');
                }
                return Future.value();
              },
              statusFn: (presentation) {
                return Future.value(
                  const FileUploadStatusResponse(nextChunkOffset: 2),
                );
              },
            );
          });

        await r.expectUploadError<Exception>();
        expect(handler.chunkCount, 2);
        expect(handler.statusCount, 0);
        expect(handler.presentationCount, 1);

        handler.chunkFn = (_, __) => Future.value();

        await r.expectRetry();
        expect(handler.chunkCount, 4);
        expect(handler.presentationCount, 1);
        expect(handler.statusCount, 1);
        expect(handler.total, 6);
      });
    },
  );
}
