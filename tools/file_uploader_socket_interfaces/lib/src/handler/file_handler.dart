import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart';
import 'package:file_uploader_socket_interfaces/src/default.dart';

/// {@template socket_file_handler}
/// A common interface for any plugin that wants to handle
/// file uploads using a socket client.
/// {@endtemplate}
abstract class SocketFileHandler<ResponseType> extends FileUploadHandler {
  /// {@macro socket_file_handler}
  ///
  /// [path], [method], [headers], [body] are request parameters
  const SocketFileHandler({
    required super.file,
    required this.path,
    this.method = kFileUploadMethod,
    this.headers,
    this.body,
    this.fileKey = kFileKey,
    this.headersCallback,
    this.fileParser = kChunkParser,
  });

  /// request `method`, default to `POST`
  final String method;

  /// request `path`
  final String path;

  /// request `headers`
  final Map<String, String>? headers;

  /// request `headers`
  final FileHeadersCallback? headersCallback;

  /// request `body`
  final String? body;

  /// request key for file
  final String fileKey;

  /// callback to validate chunk upload
  final ChunkParser<ResponseType> fileParser;
}
