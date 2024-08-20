import 'dart:async';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:flutter_file_uploader/src/file_uploader/model.dart';
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

          final callback = model.onPressedAddFiles(
            onFileAdded: (file) async {
              return MockFileUploadHandler();
            },
            onPressedAddFiles: () async {
              await Future<void>.delayed(const Duration(milliseconds: 10));
              return [utils.createFile()];
            },
          );
          unawaited(callback?.call());
          await Future<void>.delayed(const Duration(milliseconds: 2));
          expect(model.processingFiles, true);

          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(model.processingFiles, false);
          expect(model.refs.length, 1);
        },
      );
    },
  );
}
