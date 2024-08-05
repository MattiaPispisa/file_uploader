import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart';
import 'package:test/test.dart';

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
    },
  );
}

class UnknownHandler extends IFileUploadHandler {
  UnknownHandler({required super.file});
}

