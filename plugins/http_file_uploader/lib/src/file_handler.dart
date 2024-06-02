import 'package:file_uploader/file_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:http_file_uploader/src/http_ext.dart';

/// [HttpFileHandler] handle the file upload using the [http.Client]
class HttpFileHandler extends FileUploadHandler {
  /// [client] used to upload the file
  ///
  /// [path], [method], [headers], [body] are [http.Client.send] parameters
  const HttpFileHandler({
    required http.Client client,
    required super.file,
    required this.path,
    this.method = 'POST',
    this.headers,
    this.body,
  }) : _client = client;

  final http.Client _client;

  /// [http.Client.send] `method`, default to `POST`
  final String method;

  /// [http.Client.send] `path`
  final String path;

  /// [http.Client.send] `headers`
  final Map<String, String>? headers;

  /// [http.Client.send] `body`
  final String? body;

  @override
  Future<void> upload({
    ProgressCallback? onProgress,
  }) async {
    final chunk = FileChunk(file: file, start: 0, end: await file.length());

    return _client
        .sendChunk(
          method: method,
          path: path,
          chunk: chunk,
          headers: headers,
          onProgress: onProgress,
        )
        .then((value) {});
  }
}
