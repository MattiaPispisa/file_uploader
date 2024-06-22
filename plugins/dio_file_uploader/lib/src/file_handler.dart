import 'package:dio/dio.dart' as dio;
import 'package:dio_file_uploader/dio_file_uploader.dart';
import 'package:dio_file_uploader/src/dio_ext.dart';
import 'package:en_file_uploader/en_file_uploader.dart';

/// [DioFileHandler] handle the file upload using the [dio.Dio.request]
class DioFileHandler extends SocketFileHandler {
  /// [client] used to upload the file
  ///
  /// [path], [method], [headers], [body] are [http.Client.send] parameters
  const DioFileHandler({
    required dio.Dio client,
    required super.file,
    required super.path,
    super.method,
    super.headers,
    super.body,
    super.fileKey,
    this.cancelToken,
  }) : _client = client;

  final dio.Dio _client;

  /// Controls cancellation of [dio.Dio]'s requests.
  final dio.CancelToken? cancelToken;

  @override
  Future<void> upload({
    ProgressCallback? onProgress,
  }) async {
    final chunk = FileChunk(
      file: file,
      start: 0,
      end: await file.length(),
    );

    await _client.sendChunk<dynamic>(
      method: method,
      path: path,
      chunk: chunk,
      fileKey: fileKey,
      cancelToken: cancelToken,
      headers: headers,
      onProgress: onProgress,
    );

    return;
  }
}
