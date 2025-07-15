import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'mocks/mock_restorable_chunked_file_upload_handler.dart';
import 'robot.dart';

void main() {
  group(
    'file_uploader - restorable handler',
    () {
      late Robot r;
      late RestorableChunkedFileUploadHandler handler;

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
                  MockRestorableChunkedFileUploadHandlerBuilder(file).build();
            });

          await r.expectUpload();
          verify(
            () => handler.uploadChunk(
              any(),
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
                final builder =
                    MockRestorableChunkedFileUploadHandlerBuilder(file)
                      ..chunkSize = size ~/ 3;
                return handler = builder.build();
              });

            await r.expectUpload();

            verify(
              () => handler.uploadChunk(
                any(),
                any(),
                onProgress: any(named: 'onProgress'),
              ),
            ).called(4);
          });

          test('should not upload an already uploaded file', () async {
            const size = 1024 * 1027;

            r = Robot()
              ..createFile(length: size)
              ..createController((file) {
                final builder =
                    MockRestorableChunkedFileUploadHandlerBuilder(file)
                      ..chunkSize = size ~/ 3;
                return handler = builder.build();
              });

            await r.expectUpload();

            verify(
              () => handler.uploadChunk(
                any(),
                any(),
                onProgress: any(named: 'onProgress'),
              ),
            ).called(4);

            await r.expectFileUploaderExceptionOnSecondUpload();
          });

          test('should stop on upload, continue in retry', () async {
            var chunkIteration = 0;
            const size = 1024 * 1027;

            r = Robot()
              ..createFile(length: size)
              ..createController((file) {
                final builder =
                    MockRestorableChunkedFileUploadHandlerBuilder(file)
                      ..chunkSize = size ~/ 3
                      ..chunkFn = () {
                        if (chunkIteration == 2) {
                          chunkIteration++;
                          throw Exception('something went wrong');
                        }
                        chunkIteration++;
                        return Future.value();
                      }
                      ..statusFn = () {
                        return Future.value(
                          const FileUploadStatusResponse(nextChunkOffset: 2),
                        );
                      };

                return handler = builder.build();
              });

            await r.expectUploadError<Exception>();

            verify(
              () => handler.uploadChunk(
                any(),
                any(),
                onProgress: any(named: 'onProgress'),
              ),
            ).called(3);
            verify(() => handler.present()).called(1);
            verifyNever(() => handler.status(any()));

            await r.expectRetry();

            // repeat the one failed, upload the last
            verify(
              () => handler.uploadChunk(
                any(),
                any(),
                onProgress: any(named: 'onProgress'),
              ),
            ).called(2);

            // not necessary
            verifyNever(() => handler.present());

            // called on retry
            verify(() => handler.status(any())).called(1);
          });

          test('should call progress on upload', () async {
            const size = 1024 * 1027;
            var onProgressCount = 0;
            final counts = <int>[];
            late int total;

            r = Robot()
              ..createFile(length: size)
              ..createController((file) {
                final builder =
                    MockRestorableChunkedFileUploadHandlerBuilder(file)
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
            const chunkSize = size ~/ 3;
            var onProgressCount = 0;
            final counts = <int>[];
            late int total;

            r = Robot()
              ..createFile(length: size)
              ..createController((file) {
                final builder =
                    MockRestorableChunkedFileUploadHandlerBuilder(file)
                      ..chunkSize = chunkSize
                      ..statusFn = () {
                        // skip first chunk
                        return Future.value(
                          const FileUploadStatusResponse(nextChunkOffset: 1),
                        );
                      };
                return handler = builder.build();
              });

            await r.expectRetry(
              onProgress: (c, t) {
                onProgressCount++;
                counts.add(c);
                total = t;
              },
            );

            // -1 from upload (skip first chunk)
            expect(onProgressCount, 4);
            expect(counts[1], greaterThan(counts[0]));
            expect(counts[2], greaterThan(counts[1]));
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
                final builder =
                    MockRestorableChunkedFileUploadHandlerBuilder(file)
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

            // With multiple calls per chunk, should have more progress calls
            expect(onProgressCount, greaterThan(5));

            // Progress should always increase or stay the same (never decrease)
            for (int i = 1; i < counts.length; i++) {
              expect(counts[i], greaterThanOrEqualTo(counts[i - 1]));
            }

            // Final count should equal total size
            expect(counts.last, size);
            expect(counts.last, total);

            // Check that we don't have incorrect accumulation
            // With old buggy logic, this would fail because counts would be way too high
            expect(counts.every((count) => count <= size), isTrue);
          });
        },
      );
    },
  );
}
