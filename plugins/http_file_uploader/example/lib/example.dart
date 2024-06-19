import 'dart:convert';
import 'dart:io';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:http_file_uploader/http_file_uploader.dart';
import 'package:http/http.dart';

main() async {
  final client = Client();
  final tempDir = Directory.systemTemp.createTempSync();
  final file = File('${tempDir.path}/file.txt')..writeAsStringSync("hi");

  final baseRequestPath = "my-request";

  final headers = {"Authorization": "Bearer XXX"};

  final restorableHandler = HttpRestorableChunkedFileHandler(
    client: client,
    file: XFile(file.path),
    presentMethod: "POST",
    chunkMethod: "PATCH",
    statusMethod: "HEAD",
    presentPath: "$baseRequestPath",
    chunkPath: (presentation, _) => "$baseRequestPath&patch=${presentation.id}",
    statusPath: (presentation) => "$baseRequestPath&status=${presentation.id}",
    presentHeaders: {
      "Upload-Length": file.lengthSync().toString(),
      ...headers,
    },
    chunkHeaders: (presentation, chunk) {
      return headers;
    },
    statusHeaders: null,
    presentParser: (response) =>
        FileUploadPresentationResponse(id: response.body),
    statusParser: (response) =>
        FileUploadStatusResponse(nextChunkOffset: jsonDecode(response.body)),
    chunkSize: 1024 * 1024, // 1mb
    presentBody: null,
    chunkBody: null,
    statusBody: null,
  );

  final controller = FileUploadController(
    restorableHandler,
    logger: PrintLogger(),
  );
  await controller.upload();

  print("done!");
}

class PrintLogger implements FileUploaderLogger {
  @override
  void error(String message, error, stackTrace) {
    print(message);
  }

  @override
  void info(String message) {
    print(message);
  }

  @override
  void warning(String message) {
    print(message);
  }
}
