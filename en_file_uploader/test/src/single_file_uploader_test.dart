import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'mocks/logger.dart';
import 'mocks/mock_file_transformer.dart';
import 'mocks/mock_file_upload_handler.dart';
import 'robot.dart';

void main() {
  group('file_uploader - file handler', () {
    late Robot r;
    late FileUploadHandler handler;

    tearDown(() {
      r.dispose();
    });

    test('should stop on upload, restart on retry', () async {
      var uploadIteration = 0;

      r = Robot()
        ..createFile()
        ..createController((file) {
          final builder = MockFileUploadHandlerBuilder(file)
            ..uploadFn = () {
              if (uploadIteration == 0) {
                uploadIteration++;
                throw Exception('something went wrong');
              }
              uploadIteration++;
              return Future.value();
            };

          return handler = builder.build();
        });

      await r.expectUploadError<Exception>();

      verify(
        () => handler.upload(
          any<XFile>(),
          onProgress: any<ProgressCallback>(named: 'onProgress'),
        ),
      ).called(1);

      await r.expectRetry();

      // repeat upload
      verify(
        () => handler.upload(
          any<XFile>(),
          onProgress: any<ProgressCallback>(named: 'onProgress'),
        ),
      ).called(1);
    });

    test('should call onProgress on upload', () async {
      var onProgressCount = 0;
      var count = 0;
      late int total;

      r = Robot()
        ..createFile()
        ..createController((file) {
          final builder = MockFileUploadHandlerBuilder(file)
            ..uploadFn = () {
              return Future.value();
            };

          return handler = builder.build();
        });

      await r.expectUpload(
        onProgress: (c, t) {
          onProgressCount++;
          count = c;
          total = t;
        },
      );

      expect(onProgressCount, 1);
      expect(count, 1024);
      expect(count, total);
    });

    test('should call onProgress on retry', () async {
      var onProgressCount = 0;
      var count = 0;
      late int total;

      r = Robot()
        ..createFile()
        ..createController((file) {
          final builder = MockFileUploadHandlerBuilder(file)
            ..uploadFn = () {
              return Future.value();
            };

          return handler = builder.build();
        });

      await r.expectRetry(
        onProgress: (c, t) {
          onProgressCount++;
          count = c;
          total = t;
        },
      );

      expect(onProgressCount, 1);
      expect(count, 1024);
      expect(count, total);
    });

    group('transform', () {
      test('should transform and cleanup after upload', () async {
        var onTransformationProgressCount = 0;
        var count = 0.0;

        late final FileTransformer transformer;

        r = Robot()
          ..createFile()
          ..addTransformer(() {
            final builder = MockFileTransformerBuilder();
            return transformer = builder.build();
          })
          ..createController(
            (file) {
              final builder = MockFileUploadHandlerBuilder(file)
                ..uploadFn = () {
                  return Future.value();
                };

              return handler = builder.build();
            },
          )
          ..expectTransformersNotApplied();

        await r.expectUpload(
          onTransformationProgress: (c) {
            onTransformationProgressCount++;
            count = c;
          },
        );

        r.expectTransformersApplied();

        expect(onTransformationProgressCount, 2);
        verify(
          () => transformer.transform(
            any<XFile>(),
            onProgress:
                any<TransformationProgressCallback>(named: 'onProgress'),
          ),
        ).called(1);
        verify(
          () => transformer.cleanup(any<XFile>()),
        ).called(1);
        expect(count, 1);
      });

      test('should stop on transformation fail if set', () async {
        late final FileTransformer transformer;

        r = Robot()
          ..createFile()
          ..addTransformer(() {
            final builder = MockFileTransformerBuilder()
              ..fail = true
              ..continueOnFailure = false;
            return transformer = builder.build();
          })
          ..createController(
            (file) {
              final builder = MockFileUploadHandlerBuilder(file)
                ..uploadFn = () {
                  return Future.value();
                };

              return handler = builder.build();
            },
          );

        await r.expectUploadError<void>();

        r.expectTransformersNotApplied();

        verify(
          () => transformer.transform(
            any<XFile>(),
            onProgress:
                any<TransformationProgressCallback>(named: 'onProgress'),
          ),
        ).called(1);
        verifyNever(
          () => transformer.cleanup(any<XFile>()),
        );
      });

      test('should track transformation progress', () async {
        var onTransformationProgressCount = 0;
        final counts = <double>[];

        r = Robot()
          ..createFile()
          ..addTransformer(() {
            final builder = MockFileTransformerBuilder()
              ..progressChunkCount = 3;
            return builder.build();
          })
          ..createController(
            (file) {
              final builder = MockFileUploadHandlerBuilder(file)
                ..uploadFn = () {
                  return Future.value();
                };

              return handler = builder.build();
            },
          );

        await r.expectUpload(
          onTransformationProgress: (c) {
            onTransformationProgressCount++;
            counts.add(c);
          },
        );

        expect(onTransformationProgressCount, 4);
        expect(counts, orderedEquals([0.0, 0.33, 0.5, 1]));
      });

      test('should remain consistent with multiple transformer', () async {
        var onTransformationProgressCount = 0;
        final counts = <double>[];

        r = Robot()
          ..createFile()
          ..addTransformer(() {
            final builder = MockFileTransformerBuilder()
              ..progressChunkCount = 3;
            return builder.build();
          })
          ..addTransformer(() {
            final builder = MockFileTransformerBuilder()
              ..progressChunkCount = 2;
            return builder.build();
          })
          ..createController(
            (file) {
              final builder = MockFileUploadHandlerBuilder(file)
                ..uploadFn = () {
                  return Future.value();
                };

              return handler = builder.build();
            },
          );

        await r.expectUpload(
          onTransformationProgress: (c) {
            onTransformationProgressCount++;
            counts.add(c);
          },
        );

        expect(onTransformationProgressCount, 6);
        expect(counts, orderedEquals([0.0, 0.17, 0.25, 0.5, 0.75, 1.0]));
      });

      test('should transform and cleanup after retry', () async {
        var onTransformationProgressCount = 0;
        var count = 0.0;

        late final FileTransformer transformer;

        r = Robot()
          ..createFile()
          ..addTransformer(() {
            final builder = MockFileTransformerBuilder();
            return transformer = builder.build();
          })
          ..createController(
            (file) {
              final builder = MockFileUploadHandlerBuilder(file)
                ..uploadFn = () {
                  return Future.value();
                };

              return handler = builder.build();
            },
          );

        await r.expectRetry(
          onTransformationProgress: (c) {
            onTransformationProgressCount++;
            count = c;
          },
        );

        r.expectTransformersApplied();

        expect(onTransformationProgressCount, 2);
        verify(
          () => transformer.transform(
            any<XFile>(),
            onProgress:
                any<TransformationProgressCallback>(named: 'onProgress'),
          ),
        ).called(1);
        verify(
          () => transformer.cleanup(any<XFile>()),
        ).called(1);
        expect(count, 1);
      });

      test('should not repeat transformers on upload error', () async {
        var uploadIteration = 0;

        late final FileTransformer transformer;

        r = Robot()
          ..createFile()
          ..addTransformer(() {
            final builder = MockFileTransformerBuilder();
            return transformer = builder.build();
          })
          ..createController((file) {
            final builder = MockFileUploadHandlerBuilder(file)
              ..uploadFn = () {
                if (uploadIteration == 0) {
                  uploadIteration++;
                  throw Exception('something went wrong');
                }
                uploadIteration++;
                return Future.value();
              };

            return handler = builder.build();
          });

        await r.expectUploadError<Exception>();

        verify(
          () => transformer.transform(
            any<XFile>(),
            onProgress:
                any<TransformationProgressCallback>(named: 'onProgress'),
          ),
        ).called(1);

        // cleanup is made only after a successful upload
        verifyNever(
          () => transformer.cleanup(any<XFile>()),
        );

        await r.expectRetry();

        verifyNever(
          () => transformer.transform(
            any<XFile>(),
            onProgress:
                any<TransformationProgressCallback>(named: 'onProgress'),
          ),
        );

        verify(
          () => transformer.cleanup(any<XFile>()),
        ).called(1);
      });

      test(
          'should warn about transformation fails'
          ' when continueOnFailure is true', () async {
        final logger = MockLogger();
        r = Robot()
          ..createFile()
          ..logger = logger
          ..addTransformer(() {
            final transformerBuilder = MockFileTransformerBuilder()
              ..fail = true;
            return transformerBuilder.build();
          })
          ..createController((file) {
            final builder = MockFileUploadHandlerBuilder(file);

            return handler = builder.build();
          });

        await r.expectUpload();

        verify(
          () => logger.info(
            any<String>(
              that: contains('applying transformers to '),
            ),
          ),
        ).called(1);
        verify(
          () => logger.warning(
            any<String>(
              that: contains('Transformer _MockFileTransformer failed on'),
            ),
          ),
        ).called(1);
      });

      test(
          'should log error about transformation fails'
          ' when continueOnFailure is false', () async {
        final logger = MockLogger();
        r = Robot()
          ..createFile()
          ..logger = logger
          ..addTransformer(() {
            final transformerBuilder = MockFileTransformerBuilder()
              ..fail = true
              ..continueOnFailure = false;
            return transformerBuilder.build();
          })
          ..createController((file) {
            final builder = MockFileUploadHandlerBuilder(file);

            return handler = builder.build();
          });

        await r.expectUploadError<Exception>();

        verify(
          () => logger.info(
            any<String>(
              that: contains('applying transformers to '),
            ),
          ),
        ).called(1);
        verify(
          () => logger.error(
            any<String>(
              that: contains('process is interrupted'),
            ),
            any<dynamic>(),
            any<dynamic>(),
          ),
        ).called(1);
      });

      test('should log info about transformation cleanup fails', () async {
        final logger = MockLogger();
        final exception = Exception('Cleanup failed');

        r = Robot()
          ..createFile()
          ..logger = logger
          ..addTransformer(() {
            final transformerBuilder = MockFileTransformerBuilder()
              ..fail = false
              ..cleanup = () => throw exception;
            return transformerBuilder.build();
          })
          ..createController((file) {
            final builder = MockFileUploadHandlerBuilder(file);

            return handler = builder.build();
          });

        await r.expectUpload();

        verify(
          () => logger.warning(
            any<String>(
              that: contains('Something went wrong during files cleanup'),
            ),
          ),
        ).called(1);
      });
    });
  });
}
