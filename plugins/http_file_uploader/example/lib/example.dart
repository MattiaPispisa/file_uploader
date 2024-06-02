import 'dart:convert';
import 'dart:io';

import 'package:file_uploader/file_uploader.dart';
import 'package:http_file_uploader/http_file_uploader.dart';
import 'package:http/http.dart';

main() async {
  final client = Client();
  final file = File("fake_file");

  final baseRequestPath = "my-server";

  final restorableHandler = HttpRestorableChunkedFileHandler(
    client: client,
    file: file,
    presentMethod: "POST",
    chunkMethod: "PATCH",
    statusMethod: "HEAD",
    presentPath: "$baseRequestPath/upload/presentation",
    chunkPath: (presentation, _) =>
        "$baseRequestPath/upload/${presentation.id}/chunk",
    statusPath: (presentation) =>
        "$baseRequestPath/upload/${presentation.id}/status",
    presentHeaders: {
      "size": file.lengthSync().toString(),
    },
    chunkHeaders: (presentation, chunk) {
      return {
        "from": chunk.start.toString(),
        "end": chunk.end.toString(),
      };
    },
    statusHeaders: null,
    presentParser: (response) =>
        FileUploadPresentationResponse(id: jsonDecode(response.body)),
    statusParser: (response) =>
        FileUploadStatusResponse(nextChunkOffset: jsonDecode(response.body)),
    chunkSize: 1024 * 1024, // 1mb
    presentBody: null, chunkBody: null,
    statusBody: null,
  );

  final controller = FileUploadController(restorableHandler);
  await controller.upload();
}
