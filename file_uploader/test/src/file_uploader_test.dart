// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:file_uploader/file_uploader.dart';
import 'package:test/test.dart';

import 'mock_restorable_chunked_file_upload_handler.dart';
import 'robot.dart';

// TODO: test da fare:
// - il tipo del runtype costruito deve essere corretto rispetto l'handler dato
// - la funzione di suiddivisione in chunks deve essere corretta

void main() {
  group('configuration', () {
    test('should set default chunk size', () {
      const size = 1027;
      setDefaultChunkSize(size);

      expect(defaultChunkSize, size);
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
        expect(handler.chunkCount, 3);
      });

      test('should stop on upload', () async {
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
                  FileUploadStatusResponse(nextChunkOffset: 2),
                );
              },
            );
          });

        await r.expectUploadError<Exception>();
        expect(handler.chunkCount, 2);
      });
    },
  );
}
