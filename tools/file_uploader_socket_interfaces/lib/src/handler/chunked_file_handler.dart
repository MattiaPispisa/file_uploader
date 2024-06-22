import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart';

/// A common interface for any plugin that wants to handle
/// file uploads using a socket client.
abstract class SocketChunkedFileHandler extends ChunkedFileUploadHandler {
  /// [path], [method], [headers], [body] are request parameters
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
  const SocketChunkedFileHandler({
    required super.file,
    required this.path,
    this.method = 'POST',
    this.fileKey = 'file',
    this.headers,
    this.body,
    super.chunkSize,
  });

  /// request `method`, default to `POST`
  final String method;

  /// request `path`
  final String path;

  /// request `headers`
  final ChunkHeadersCallback? headers;

  /// request `body`
  final String? body;

  /// request key for file
  final String fileKey;
}
