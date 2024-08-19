# Http File Uploader

[![License: MIT][license_badge]][license_link]
[![coverage][coverage_badge]][coverage_badge]

A [en_file_uploader](https://pub.dev/packages/en_file_uploader) plugin to handle the file upload using [http](https://pub.dev/packages/http) package.

**`http_file_uploader` requires `en_file_uploader` package.
More info about `en_file_uploader` [here](https://pub.dev/packages/en_file_uploader)**

## Features

- use `HttpFileHandler` to handle a file upload;
- use `HttpChunkedFileHandler` to handle a file upload in chunk;
- use `HttpRestorableChunkedFileHandler` to handle a file upload in chunk with the capability to restore the upload.

## Usage

1. Create a new instance of `HttpFileHandler`, `HttpChunkedFileHandler` or `HttpRestorableChunkedFileHandler`.
2. Create a `FileUploadController` with the created handler
3. Call `controller.upload`

```dart
import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:http_file_uploader/http_file_uploader.dart';
import 'package:http/http.dart';

main() async {
  final client = Client();
  final file = XFile("fake_file");

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

```

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[coverage_badge]: https://img.shields.io/badge/coverage-100%25-green