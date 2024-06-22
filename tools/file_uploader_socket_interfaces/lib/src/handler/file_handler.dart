import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart';
import 'package:file_uploader_socket_interfaces/src/default.dart';

/// A common interface for any plugin that wants to handle
/// file uploads using a socket client.
abstract class SocketFileHandler<ResponseType> extends FileUploadHandler {
  /// [path], [method], [headers], [body] are request parameters
  const SocketFileHandler({
    required super.file,
    required this.path,
    this.method = kFileUploadMethod,
    this.headers,
    this.body,
    this.fileKey = kFileKey,
    this.fileParser = kChunkParser,
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

  /// callback to validate chunk upload
  final ChunkParser<ResponseType> fileParser;
}
