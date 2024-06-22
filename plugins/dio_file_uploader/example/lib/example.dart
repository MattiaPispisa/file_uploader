import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_file_uploader/dio_file_uploader.dart';
import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;

main() async {
  final client = Dio();
  final file = utils.createIoFile();

  final baseRequestPath = "my-request";

  final headers = {"Authorization": "Bearer XXX"};

  final restorableHandler = DioRestorableChunkedFileHandler(
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
        FileUploadPresentationResponse(id: response.data),
    statusParser: (response) =>
        FileUploadStatusResponse(nextChunkOffset: jsonDecode(response.data)),
    chunkSize: 1024 * 1024, // 1mb
    presentBody: null,
    chunkBody: null,
    statusBody: null,
  );

  final controller = FileUploadController(
    restorableHandler,
    logger: utils.PrintLogger(),
  );
  await controller.upload();

  print("done!");
}
