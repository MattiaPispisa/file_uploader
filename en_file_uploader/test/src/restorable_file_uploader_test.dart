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
        },
      );
    },
  );
}
