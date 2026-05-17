import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:test/test.dart';

class _ImplFileTransformer extends FileTransformer {
  @override
  Future<XFile> transform(
    XFile file, {
    TransformationProgressCallback? onProgress,
  }) {
    return Future.value(file);
  }
}

void main() {
  group('file_transformer', () {
    test('default should not continue on failure ', () {
      expect(_ImplFileTransformer().continueOnFailure, false);
    });

    test('should no op cleanup', () async {
      await expectLater(
        () => _ImplFileTransformer().cleanup(utils.createFile()),
        returnsNormally,
      );
    });
  });
}
