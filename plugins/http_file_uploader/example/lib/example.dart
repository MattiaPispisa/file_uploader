import 'dart:convert';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:http/http.dart';
import 'package:http_file_uploader/http_file_uploader.dart';

void main() async {
  final client = Client();
  final file = utils.createIoFile();

  const baseRequestPath = 'my-request';

  final headers = {'Authorization': 'Bearer XXX'};

  final restorableHandler = HttpRestorableChunkedFileHandler(
    client: client,
    file: XFile(file.path),
    chunkMethod: 'PATCH',
    presentPath: baseRequestPath,
    chunkPath: (presentation, _) => '$baseRequestPath&patch=${presentation.id}',
    statusPath: (presentation) => '$baseRequestPath&status=${presentation.id}',
    presentHeaders: {
      'Upload-Length': file.lengthSync().toString(),
      ...headers,
    },
    chunkHeaders: (presentation, chunk) {
      return headers;
    },
    presentParser: (response) =>
        FileUploadPresentationResponse(id: response.body),
    statusParser: (response) => FileUploadStatusResponse(
      nextChunkOffset: jsonDecode(response.body) as int,
    ),
    chunkSize: 1024 * 1024, // 1mb
  );

  final controller = FileUploadController(
    restorableHandler,
    logger: utils.PrintLogger(),
  );
  await controller.upload();

  // print("done!");
}
