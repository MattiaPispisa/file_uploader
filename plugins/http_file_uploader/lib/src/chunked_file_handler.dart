import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:http_file_uploader/src/http_ext.dart';

/// [HttpChunkedFileHandler] handle the file upload in chunks
class HttpChunkedFileHandler extends ChunkedFileUploadHandler {
  /// [client] used to upload the file
  ///
  /// [path], [method], [headers], [body] are [http.Client.send] parameters
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
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

  /// [http.Client.send] `method`, default to `POST`
  final String method;

  /// [http.Client.send] `path`
  final String path;

  /// [http.Client.send] `headers`
  final ChunkHeadersCallback? headers;

  /// [http.Client.send] `body`
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

/// compose [http.Client.send] `headers` from on [FileChunk]
typedef ChunkHeadersCallback = Map<String, String> Function(
  FileChunk chunk,
);
