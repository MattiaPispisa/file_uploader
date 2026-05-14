import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:http_file_uploader/http_file_uploader.dart';
import 'package:http_file_uploader/src/http_ext.dart';

/// {@template http_file_handler}
/// [HttpFileHandler] handle the file upload using the [http.Client]
/// {@endtemplate}
class HttpFileHandler extends SocketFileHandler<http.Response> {
  /// {@macro http_file_handler}
  /// 
  /// [client] used to upload the file
  ///
  /// [path], [method], [headers], [body] are [http.Client.send] parameters
  const HttpFileHandler({
    required http.Client client,
    required super.file,
    required super.path,
    super.method,
    super.headers,
    super.body,
    super.fileKey,
  }) : _client = client;

  final http.Client _client;

  @override
  Future<void> upload(
    XFile file, {
    ProgressCallback? onProgress,
  }) async {
    final chunk = FileChunk(file: file, start: 0, end: await file.length());

    return _client
        .sendStreamedChunk(
          method: method,
          path: path,
          chunk: chunk,
          headers: headersCallback != null ? headersCallback!(file) : headers,
          fileKey: fileKey,
          onProgress: onProgress,
        )
        .then(fileParser);
  }
}
