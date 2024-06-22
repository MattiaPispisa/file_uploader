import 'package:en_file_uploader/en_file_uploader.dart';

/// A common interface for any plugin that wants to handle
/// file uploads using a socket client.
abstract class SocketFileHandler extends FileUploadHandler {
  /// [path], [method], [headers], [body] are request parameters
  const SocketFileHandler({
    required super.file,
    required this.path,
    this.method = 'POST',
    this.headers,
    this.body,
    this.fileKey = 'file',
  });

  /// request `method`, default to `POST`
  final String method;

  /// request `path`
  final String path;

  /// request `headers`
  final Map<String, String>? headers;

  /// request `body`
  final String? body;

  /// request key for file
  final String fileKey;
}
