import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart';
import 'package:test/test.dart';

import 'mocks/mock_chunked_file_upload_handler.dart';
import 'mocks/mock_file_transformer.dart';
import 'mocks/mock_file_upload_handler.dart';
import 'mocks/mock_restorable_chunked_file_upload_handler.dart';

void main() {
  group(
    'file uploader controller',
    () {
      test(
        'should throw exception on unknown handler',
        () {
          final file = createFile();
          expect(
            () => FileUploadController(UnknownHandler(file: file)),
            throwsA(isA<UnexpectedHandlerException>()),
          );
        },
      );

      test('should have transformers', () async {
        final file = createFile();
        final controller = FileUploadController(
          MockFileUploadHandlerBuilder(file).build(),
          transformers: [MockFileTransformerBuilder().build()],
        );

        expect(controller.hasTransformers, true);
      });

      test('should not have transformers', () async {
        final file = createFile();
        final controller = FileUploadController(
          MockFileUploadHandlerBuilder(file).build(),
        );

        expect(controller.hasTransformers, false);
      });

      test('should expose originalFile for _FileUploadController', () async {
        final file = createFile();
        final controller = FileUploadController(
          MockFileUploadHandlerBuilder(file).build(),
        );

        expect(controller.originalFile, file);
      });

      test('should expose originalFile for _ChunkedFileUploadController',
          () async {
        final file = createFile();
        final controller = FileUploadController(
          MockChunkedFileUploadHandlerBuilder(file).build(),
        );

        expect(controller.originalFile, file);
      });

      test(
          'should expose originalFile for'
          ' _RestorableChunkedFileUploadController', () async {
        final file = createFile();
        final controller = FileUploadController(
          MockRestorableChunkedFileUploadHandlerBuilder(file).build(),
        );

        expect(controller.originalFile, file);
      });
    },
  );
}

class UnknownHandler extends IFileUploadHandler {
  const UnknownHandler({required super.file});
}
