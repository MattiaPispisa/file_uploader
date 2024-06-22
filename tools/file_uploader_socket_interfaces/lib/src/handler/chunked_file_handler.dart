import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart';
import 'package:file_uploader_socket_interfaces/src/default.dart';

/// A common interface for any plugin that wants to handle
/// file uploads using a socket client.
abstract class SocketChunkedFileHandler<ResponseType>
    extends ChunkedFileUploadHandler {
  /// [path], [method], [headers], [body] are request parameters
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
  const SocketChunkedFileHandler({
    required super.file,
    required this.path,
    super.chunkSize,
    this.method = kFileUploadMethod,
    this.fileKey = kFileKey,
    this.headers,
    this.body,
    this.chunkParser = kChunkParser,
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

  /// callback to validate chunk upload
  final ChunkParser<ResponseType> chunkParser;
}
