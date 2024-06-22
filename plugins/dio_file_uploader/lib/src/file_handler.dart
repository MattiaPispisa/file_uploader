import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:dio/dio.dart' as dio;

/// [HttpFileHandler] handle the file upload using the [http.Client]
class HttpFileHandler extends FileUploadHandler {
  /// [client] used to upload the file
  ///
  /// [path], [method], [headers], [body] are [http.Client.send] parameters
  const HttpFileHandler({
    required dio.Dio client,
    required super.file,
    required this.path,
    this.method = 'POST',
    this.headers,
    this.body,
    this.fileKey = 'file',
  }) : _client = client;

  final dio.Dio _client;

  /// [dio.Dio.request] `method`, default to `POST`
  final String method;

  /// [dio.Dio.request] `path`
  final String path;

  /// [dio.Dio.request] `headers`
  final Map<String, String>? headers;

  /// [dio.Dio.request] `body`
  final String? body;

    /// [dio.Dio.request] `formData` file key
  final String fileKey;

  @override
  Future<void> upload({
    ProgressCallback? onProgress,
  }) async {
    final chunk = FileChunk(
      file: file,
      start: 0,
      end: await file.length(),
    );

            final formData = dio.FormData.fromMap({
              fileKey: dio.MultipartFile.fromStream(
                () => chunk.file.openRead(chunk.start,chunk.end),
                        chunk.end - chunk.start,

              ),
            });


    await _client.request(
      path,
      data: 
    );

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
