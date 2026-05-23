import 'dart:async';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFileUploadHandler extends Mock implements FileUploadHandler {}

class MockFile extends Mock implements XFile {}

void main() {
  group(
    'FileUploaderModel',
    () {
      setUpAll(() {
        registerFallbackValue(MockFile());
      });

      test(
        'should construct correctly',
        () {
          final model = FileUploaderModel();
          expect(model.refs, isEmpty);
          expect(model.processingFiles, false);
          expect(model.errorOnFiles, isNull);
        },
      );

      test(
        'onPressedAddFiles should return correctly',
        () {
          var model = FileUploaderModel(
            onPressedAddFiles: () async => [utils.createFile()],
          );

          var callback = model.onPressedAddFiles();
          expect(callback, isNull);

          model = FileUploaderModel(
            onFileAdded: (file) async => MockFileUploadHandler(),
          );

          callback = model.onPressedAddFiles();
          expect(callback, isNull);

          model = FileUploaderModel(
            onFileAdded: (file) async => MockFileUploadHandler(),
            onPressedAddFiles: () async => [utils.createFile()],
          );

          callback = model.onPressedAddFiles();

          expect(callback, isNotNull);
        },
      );

      test(
        'should add file on onPressedAddFiles',
        () async {
          final file = utils.createFile();
          final handler = MockFileUploadHandler();

          final model = FileUploaderModel(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              await Future<void>.delayed(const Duration(milliseconds: 10));
              return [file];
            },
          );

          when(() => handler.originalFile).thenReturn(file);

          final callback = model.onPressedAddFiles();
          unawaited(callback?.call());
          await Future<void>.delayed(const Duration(milliseconds: 2));
          expect(model.processingFiles, true);

          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(model.processingFiles, false);
          expect(model.refs.length, 1);
          expect(
            model.refs.first,
            isA<FileUploaderRef>()
                .having((ref) => ref.uploaded, 'uploaded', false)
                .having(
                  (ref) => ref.originalFile,
                  'originalFile',
                  file,
                ),
          );
        },
      );

      test('should add file on addFiles', () async {
        final file = utils.createFile();
        final handler = MockFileUploadHandler();

        final model = FileUploaderModel(
          onFileAdded: (file) async {
            return handler;
          },
        );

        await model.addFiles([file]);

        expect(model.refs.length, 1);
      });

      test(
        'should handle errors on add file',
        () async {
          final handler = MockFileUploadHandler();
          final model = FileUploaderModel(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              throw Error();
            },
          );

          final callback = model.onPressedAddFiles();
          await callback?.call();

          expect(model.refs, isEmpty);
          expect(model.processingFiles, false);
          expect(model.errorOnFiles, isNotNull);
        },
      );

      test(
        'should handle errors on pressed add files',
        () async {
          final model = FileUploaderModel(
            onFileAdded: (file) async {
              throw Error();
            },
            onPressedAddFiles: () async {
              return [utils.createFile()];
            },
          );

          final callback = model.onPressedAddFiles();
          await callback?.call();

          expect(model.refs, isEmpty);
          expect(model.processingFiles, false);
          expect(model.errorOnFiles, isNotNull);
        },
      );

      test(
        'should upload file',
        () async {
          final handler = MockFileUploadHandler();
          final file = utils.createFile();

          final model = FileUploaderModel(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              return [file];
            },
          );

          when(
            () => handler.upload(
              any<XFile>(),
              onProgress: any(named: 'onProgress'),
            ),
          ).thenAnswer((_) async => {});
          when(() => handler.originalFile).thenReturn(file);

          final callback = model.onPressedAddFiles();
          await callback?.call();

          final first = model.refs.first;
          await first.upload();
          expect(first.uploaded, true);
        },
      );

      test(
        'should retry file',
        () async {
          final handler = MockFileUploadHandler();
          final file = utils.createFile();

          final model = FileUploaderModel(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              return [file];
            },
          );

          when(
            () => handler.upload(any(), onProgress: any(named: 'onProgress')),
          ).thenAnswer((_) async => {});
          when(() => handler.originalFile).thenReturn(file);

          final callback = model.onPressedAddFiles();
          await callback?.call();

          final first = model.refs.first;
          await first.retry();
          expect(first.uploaded, true);
        },
      );

      test(
        'should upload and remove file',
        () async {
          final handler = MockFileUploadHandler();
          final file = utils.createFile();

          final model = FileUploaderModel(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              return [file];
            },
          );

          when(
            () => handler.upload(any(), onProgress: any(named: 'onProgress')),
          ).thenAnswer((_) async => {});
          when(() => handler.originalFile).thenReturn(file);

          final callback = model.onPressedAddFiles();
          await callback?.call();

          final first = model.refs.first;
          await first.upload();
          first.onRemoved();

          expect(model.refs, isEmpty);
        },
      );

      test(
        'should apply transformers',
        () async {
          final handler = MockFileUploadHandler();
          final file = utils.createFile();

          final model = FileUploaderModel(
            onFileAdded: (_) async => handler,
            onPressedAddFiles: () async => [file],
            transformers: [_NoOpTransformer()],
          );

          when(
            () => handler.upload(
              any<XFile>(),
              onProgress: any(named: 'onProgress'),
            ),
          ).thenAnswer((_) async => {});
          when(() => handler.originalFile).thenReturn(file);

          final callback = model.onPressedAddFiles();
          await callback?.call();

          final first = model.refs.first;

          expect(first.hasTransformers, true);

          await first.upload();
          expect(first.transformersApplied, true);
        },
      );
    },
  );
}

class _NoOpTransformer extends FileTransformer {
  @override
  Future<XFile> transform(
    XFile file, {
    TransformationProgressCallback? onProgress,
  }) async {
    return file;
  }
}
