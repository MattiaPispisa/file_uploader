import 'package:file_uploader/file_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:http_file_uploader/src/http_ext.dart';

class HttpChunkedFileHandler extends ChunkedFileUploadHandler {
  const HttpChunkedFileHandler({
    required http.Client client,
    required super.file,
    required this.path,
    this.method = 'POST',
    this.headers,
    this.body,
    super.chunkSize,
  }) : _client = client;

  final http.Client _client;

  final String method;
  final String path;
  final ChunkHeadersCallback? headers;
  final String? body;

  @override
  Future<void> uploadChunk(
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) async {
    return _client
        .sendChunk(
          method: method,
          path: path,
          chunk: chunk,
          headers: headers?.call(chunk),
          onProgress: onProgress,
        )
        .then((value) => {});
  }
}

typedef ChunkHeadersCallback = Map<String, String> Function(
  FileChunk chunk,
);
