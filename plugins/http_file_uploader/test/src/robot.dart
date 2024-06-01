import 'dart:io';
import 'dart:math';

import 'package:file_uploader/file_uploader.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/expect.dart';
import 'package:test/test.dart';

class HttpRobot {
  factory HttpRobot(Future<Response> Function(Request) fn) {
    return HttpRobot._(MockClient(fn));
  }

  HttpRobot._(this._client);

  final Client _client;
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
    IFileUploadHandler Function(Client client, File file) handler,
  ) {
    _controller = FileUploadController(handler(_client, _file));
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
}

Future<Response> Function(Request) mockClientFn({
  Response? Function()? onPresentation,
  Response? Function()? onChunk,
  Response? Function()? onStatus,
}) {
  return (request) {
    var response = Response('', 200);

    if (request.url.path.contains('presentation')) {
      final presentationResponse = onPresentation?.call();
      if (presentationResponse != null) {
        response = presentationResponse;
      }
    }

    if (request.url.path.contains('chunks/')) {
      final chunkResponse = onChunk?.call();
      if (chunkResponse != null) {
        response = chunkResponse;
      }
    }

    if (request.url.path.contains('status')) {
      final statusResponse = onStatus?.call();
      if (statusResponse != null) {
        response = statusResponse;
      }
    }

    return Future.value(response);
  };
}
