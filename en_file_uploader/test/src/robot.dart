import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:test/test.dart';

class Robot {
  Robot();

  late XFile _file;
  late FileUploadController _controller;

  void createFile({
    int length = 1024,
  }) {
    _file = utils.createFile(length: length);
  }

  void createController(
    IFileUploadHandler Function(XFile file) handler,
  ) {
    _controller = FileUploadController(handler(_file));
  }

  Future<void> expectUpload() async {
    await _controller.upload();

    expect(
      () {},
      returnsNormally,
    );
  }

  Future<void> expectRetry() async {
    await _controller.retry();

    expect(
      () {},
      returnsNormally,
    );
  }

  Future<void> expectUploadError<T>() async {
    await expectLater(
      _controller.upload(),
      throwsA(isA<T>()),
    );
  }
}
