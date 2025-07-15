import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'mocks/mock_chunked_file_upload_handler.dart';
import 'robot.dart';

void main() {
  group(
    'file_uploader - chunked handler',
    () {
      late Robot r;
      late ChunkedFileUploadHandler handler;

      tearDown(() {
        r.dispose();
      });

      group('configuration', () {
        test('should set default chunk size', () async {
          const size = 1027;
          setDefaultChunkSize(size);

          expect(defaultChunkSize, size);

          r = Robot()
            ..createFile(length: size + 100)
            ..createController((file) {
              return handler =
                  MockChunkedFileUploadHandlerBuilder(file).build();
            });

          await r.expectUpload();
          verify(
            () => handler.uploadChunk(
              any(),
              onProgress: any(named: 'onProgress'),
            ),
          ).called(2);
        });
      });

      group(
        'upload',
        () {
          test('should split in chunk', () async {
            const size = 1024 * 1027;

            r = Robot()
              ..createFile(length: size)
              ..createController((file) {
                final builder = MockChunkedFileUploadHandlerBuilder(file)
                  ..chunkSize = size ~/ 3;
                return handler = builder.build();
              });

            await r.expectUpload();

            verify(
              () => handler.uploadChunk(
                any(),
                onProgress: any(named: 'onProgress'),
              ),
            ).called(4);
          });

          test('should stop on upload, restart on retry', () async {
            var chunkIteration = 0;
            const size = 1024 * 1027;

            r = Robot()
              ..createFile(length: size)
              ..createController((file) {
                final builder = MockChunkedFileUploadHandlerBuilder(file)
                  ..chunkSize = size ~/ 3
                  ..chunkFn = () {
                    if (chunkIteration == 2) {
                      chunkIteration++;
                      throw Exception('something went wrong');
                    }
                    chunkIteration++;
                    return Future.value();
                  };

                return handler = builder.build();
              });

            await r.expectUploadError<Exception>();

            verify(
              () => handler.uploadChunk(
                any(),
                onProgress: any(named: 'onProgress'),
              ),
            ).called(3);

            await r.expectRetry();

            // repeat all
            verify(
              () => handler.uploadChunk(
                any(),
                onProgress: any(named: 'onProgress'),
              ),
            ).called(4);
          });

          test('should call progress on upload', () async {
            const size = 1024 * 1027;
            var onProgressCount = 0;
            final counts = <int>[];
            late int total;

            r = Robot()
              ..createFile(length: size)
              ..createController((file) {
                final builder = MockChunkedFileUploadHandlerBuilder(file)
                  ..chunkSize = size ~/ 3;
                return handler = builder.build();
              });

            await r.expectUpload(
              onProgress: (c, t) {
                onProgressCount++;
                counts.add(c);
                total = t;
              },
            );

            expect(onProgressCount, 5);
            expect(counts[1], greaterThan(counts[0]));
            expect(counts[2], greaterThan(counts[1]));
            expect(counts[3], greaterThan(counts[2]));
            expect(counts.last, size);
            expect(counts.last, total);

            // Ensure no progress value exceeds total file size
            expect(counts.every((count) => count <= size), isTrue);
            // Ensure progress is monotonic (never decreases)
            for (int i = 1; i < counts.length; i++) {
              expect(counts[i], greaterThanOrEqualTo(counts[i - 1]));
            }
          });

          test('should call progress on retry', () async {
            const size = 1024 * 1027;
            var onProgressCount = 0;
            final counts = <int>[];
            late int total;

            r = Robot()
              ..createFile(length: size)
              ..createController((file) {
                final builder = MockChunkedFileUploadHandlerBuilder(file)
                  ..chunkSize = size ~/ 3;
                return handler = builder.build();
              });

            await r.expectRetry(
              onProgress: (c, t) {
                onProgressCount++;
                counts.add(c);
                total = t;
              },
            );

            expect(onProgressCount, 5);
            expect(counts[1], greaterThan(counts[0]));
            expect(counts[2], greaterThan(counts[1]));
            expect(counts[3], greaterThan(counts[2]));
            expect(counts.last, size);
            expect(counts.last, total);

            expect(counts.every((count) => count <= size), isTrue);
            // Ensure progress is monotonic (never decreases)
            for (int i = 1; i < counts.length; i++) {
              expect(counts[i], greaterThanOrEqualTo(counts[i - 1]));
            }
          });

          test('should handle multiple progress calls per chunk (Dio-style)',
              () async {
            const size = 1024 * 1027;
            var onProgressCount = 0;
            final counts = <int>[];
            late int total;

            r = Robot()
              ..createFile(length: size)
              ..createController((file) {
                final builder = MockChunkedFileUploadHandlerBuilder(file)
                  ..chunkSize = size ~/ 3
                  ..simulateMultipleProgressCalls =
                      true; // Simulate Dio behavior
                return handler = builder.build();
              });

            await r.expectUpload(
              onProgress: (c, t) {
                onProgressCount++;
                counts.add(c);
                total = t;
              },
            );

            expect(onProgressCount, greaterThan(5));

            for (int i = 1; i < counts.length; i++) {
              expect(counts[i], greaterThanOrEqualTo(counts[i - 1]),
                  reason:
                      'Progress should never decrease: ${counts[i - 1]} -> ${counts[i]}');
            }

            // Final count should equal total size
            expect(counts.last, size);
            expect(counts.last, total);

            expect(counts.every((count) => count <= size), isTrue);
          });
        },
      );
    },
  );
}
