import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:http_file_uploader/http_file_uploader.dart';
import 'package:http_file_uploader/src/http_ext.dart';

/// [HttpChunkedFileHandler] handle the file upload in chunks
class HttpChunkedFileHandler extends SocketChunkedFileHandler<http.Response> {
  /// [client] used to upload the file
  ///
  /// [path], [method], [headers], [body] are [http.Client.send] parameters
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
  const HttpChunkedFileHandler({
    required http.Client client,
    required super.file,
    required super.path,
    super.method,
    super.headers,
    super.body,
    super.chunkSize,
    super.fileKey,
    super.chunkParser,
    this.streamedRequest = true,
  }) : _client = client;

  final http.Client _client;

  /// if `true` use a [http.StreamedRequest] to upload the chunk
  /// else use a [http.Request].
  ///
  /// default is `true`
  final bool streamedRequest;

  @override
  Future<void> uploadChunk(
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) async {
    if (streamedRequest) {
      return _client
          .sendStreamedChunk(
            method: method,
            path: path,
            chunk: chunk,
            fileKey: fileKey,
            headers: headers?.call(chunk),
            onProgress: onProgress,
          )
          .then(chunkParser);
    }
    return _client
        .sendSimpleChunk(
          method: method,
          path: path,
          chunk: chunk,
          fileKey: fileKey,
          headers: headers?.call(chunk),
          onProgress: onProgress,
        )
        .then(chunkParser);
  }
}
