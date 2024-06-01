import 'package:file_uploader/file_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:http_file_uploader/src/http_ext.dart';

class HttpFileHandler extends FileUploadHandler {
  const HttpFileHandler({
    required http.Client client,
    required super.file,
    required this.path,
    this.method = 'POST',
    this.headers,
    this.body,
  }) : _client = client;

  final http.Client _client;

  final String method;
  final String path;
  final Map<String, String>? headers;
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
