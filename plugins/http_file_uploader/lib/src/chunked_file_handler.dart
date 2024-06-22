import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:http_file_uploader/http_file_uploader.dart';
import 'package:http_file_uploader/src/http_ext.dart';

/// [HttpChunkedFileHandler] handle the file upload in chunks
class HttpChunkedFileHandler extends SocketChunkedFileHandler {
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
  }) : _client = client;

  final http.Client _client;

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
          fileKey: fileKey,
          headers: headers?.call(chunk),
          onProgress: onProgress,
        )
        .then((value) => {});
  }
}
