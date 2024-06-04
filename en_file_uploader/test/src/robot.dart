import 'dart:io';
import 'dart:math';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:test/test.dart';

class Robot {
  Robot();

  late File _file;
  late FileUploadController _controller;

  void createFile({
    int length = 1024,
  }) {
    final tempDir = Directory.systemTemp.createTempSync();
    _file = File('${tempDir.path}/file.txt');

    final random = Random();
    final buffer = List<int>.generate(length, (_) => random.nextInt(256));
    _file.writeAsBytesSync(buffer);
  }

  void createController(
    IFileUploadHandler Function(File file) handler,
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
