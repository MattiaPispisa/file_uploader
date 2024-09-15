import 'dart:async';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFileUploadController extends Mock implements FileUploadController {}

class MockFileUploadHandler extends Mock implements FileUploadHandler {}

void main() {
  group(
    'FileUploaderModel',
        () {
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
          final model = FileUploaderModel();

          var callback = model.onPressedAddFiles(
            onPressedAddFiles: () async => [utils.createFile()],
          );
          expect(callback, isNull);

          callback = model.onPressedAddFiles(
            onFileAdded: (file) async => MockFileUploadHandler(),
          );
          expect(callback, isNull);

          callback = model.onPressedAddFiles();
          expect(callback, isNull);

          callback = model.onPressedAddFiles(
            onFileAdded: (file) async => MockFileUploadHandler(),
            onPressedAddFiles: () async => [utils.createFile()],
          );
          expect(callback, isNotNull);
        },
      );

      test(
        'should add file',
            () async {
          final model = FileUploaderModel();
          final file = utils.createFile();
          final handler = MockFileUploadHandler();

          final callback = model.onPressedAddFiles(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              await Future<void>.delayed(const Duration(milliseconds: 10));
              return [file];
            },
          );
          unawaited(callback?.call());
          await Future<void>.delayed(const Duration(milliseconds: 2));
          expect(model.processingFiles, true);

          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(model.processingFiles, false);
          expect(model.refs.length, 1);
          expect(
            model.refs.first,
            isA<FileUploaderRef>()
                .having((ref) => ref.uploaded, 'uploaded', false),
          );
        },
      );

      test(
        'should handle errors on add file',
            () async {
          final model = FileUploaderModel();
          final handler = MockFileUploadHandler();

          final callback = model.onPressedAddFiles(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              throw Error();
            },
          );
          await callback?.call();

          expect(model.refs, isEmpty);
          expect(model.processingFiles, false);
          expect(model.errorOnFiles, isNotNull);
        },
      );

      test(
        'should upload file',
            () async {
          final model = FileUploaderModel();
          final handler = MockFileUploadHandler();
          final file = utils.createFile();

          when(() => handler.upload(onProgress: any(named: 'onProgress')))
              .thenAnswer((_) async => {});
          when(() => handler.file).thenReturn(file);

          final callback = model.onPressedAddFiles(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              return [file];
            },
          );
          await callback?.call();

          final first = model.refs.first;
          await first.upload();
          expect(first.uploaded, true);
        },
      );

      test(
        'should upload file (deprecated)',
            () async {
          final model = FileUploaderModel();
          final handler = MockFileUploadHandler();
          final file = utils.createFile();

          when(() => handler.upload(onProgress: any(named: 'onProgress')))
              .thenAnswer((_) async => {});
          when(() => handler.file).thenReturn(file);

          final callback = model.onPressedAddFiles(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              return [file];
            },
          );
          await callback?.call();

          final first = model.refs.first;
          final fileResult = await first.controller.upload();
          first.onUpload(fileResult);
          expect(first.uploaded, true);
        },
      );

      test(
        'should retry file',
            () async {
          final model = FileUploaderModel();
          final handler = MockFileUploadHandler();
          final file = utils.createFile();

          when(() => handler.upload(onProgress: any(named: 'onProgress')))
              .thenAnswer((_) async => {});
          when(() => handler.file).thenReturn(file);

          final callback = model.onPressedAddFiles(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              return [file];
            },
          );
          await callback?.call();

          final first = model.refs.first;
          await first.retry();
          expect(first.uploaded, true);
        },
      );

      test(
        'should retry file (deprecated)',
            () async {
          final model = FileUploaderModel();
          final handler = MockFileUploadHandler();
          final file = utils.createFile();

          when(() => handler.upload(onProgress: any(named: 'onProgress')))
              .thenAnswer((_) async => {});
          when(() => handler.file).thenReturn(file);

          final callback = model.onPressedAddFiles(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              return [file];
            },
          );
          await callback?.call();

          final first = model.refs.first;
          final fileResult = await first.controller.retry();
          first.onUpload(fileResult);
          expect(first.uploaded, true);
        },
      );

      test(
        'should upload and remove file',
            () async {
          final model = FileUploaderModel();
          final handler = MockFileUploadHandler();
          final file = utils.createFile();

          when(() => handler.upload(onProgress: any(named: 'onProgress')))
              .thenAnswer((_) async => {});
          when(() => handler.file).thenReturn(file);

          final callback = model.onPressedAddFiles(
            onFileAdded: (file) async {
              return handler;
            },
            onPressedAddFiles: () async {
              return [file];
            },
          );
          await callback?.call();

          final first = model.refs.first;
          await first.upload();
          first.onRemoved();

          expect(model.refs, isEmpty);
        },
      );
    },
  );
}
