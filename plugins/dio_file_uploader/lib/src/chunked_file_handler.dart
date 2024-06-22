import 'package:dio/dio.dart' as dio;
import 'package:dio_file_uploader/dio_file_uploader.dart';
import 'package:dio_file_uploader/src/dio_ext.dart';
import 'package:en_file_uploader/en_file_uploader.dart';

/// [DioChunkedFileHandler] handle the file upload in chunks
class DioChunkedFileHandler
    extends SocketChunkedFileHandler<dio.Response<dynamic>> {
  /// [client] used to upload the file
  ///
  /// [path], [method], [headers], [body] are [http.Client.send] parameters
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
  const DioChunkedFileHandler({
    required dio.Dio client,
    required super.file,
    required super.path,
    super.method,
    super.headers,
    super.body,
    super.chunkSize,
    super.fileKey,
    super.chunkParser,
    this.cancelToken,
  }) : _client = client;

  final dio.Dio _client;

  /// Controls cancellation of [dio.Dio]'s requests.
  final dio.CancelToken? cancelToken;

  @override
  Future<void> uploadChunk(
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) async {
    await _client
        .sendChunk<dynamic>(
          method: method,
          path: path,
          chunk: chunk,
          fileKey: fileKey,
          cancelToken: cancelToken,
          headers: headers?.call(chunk),
          onProgress: onProgress,
        )
        .then(chunkParser);

    return;
  }
}
