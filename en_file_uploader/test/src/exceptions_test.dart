import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'exceptions',
    () {
      test(
        'FileUploaderException',
        () {
          final file = createFile();
          final exception = UnexpectedHandlerException(
            handler: UnknownHandler(file: file),
          );
          expect(exception.toString(), 'unexpected handler UnknownHandler');
        },
      );

      test(
        'FileAlreadyUploadedException',
        () {
          const exception = FileAlreadyUploadedException();
          expect(exception.toString(), 'file already uploaded');
        },
      );
    },
  );
}

class UnknownHandler extends IFileUploadHandler {
  UnknownHandler({required super.file});
}
