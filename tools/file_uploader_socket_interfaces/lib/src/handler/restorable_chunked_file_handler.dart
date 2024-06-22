import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart';

/// A common interface for any plugin that wants to handle
/// file uploads using a socket client.
abstract class SocketRestorableChunkedFileHandler<ResponseType>
    extends RestorableChunkedFileUploadHandler {
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
  const SocketRestorableChunkedFileHandler({
    required super.file,
    required this.presentPath,
    required this.chunkPath,
    required this.statusPath,
    required this.presentParser,
    required this.statusParser,
    this.presentMethod = 'POST',
    this.chunkMethod = 'POST',
    this.statusMethod = 'HEAD',
    this.presentHeaders,
    this.chunkHeaders,
    this.statusHeaders,
    this.presentBody,
    this.chunkBody,
    this.statusBody,
    this.fileKey = 'file',
    super.chunkSize,
  });

  /// [http.Client.send] `method` used on presentation
  final String presentMethod;

  /// [http.Client.send] `method` used on chunk upload
  final String chunkMethod;

  /// [http.Client.send] `method` used on status
  final String statusMethod;

  /// [http.Client.send] `path` used on presentation
  final String presentPath;

  /// [http.Client.send] `path` used on chunk upload
  final ChunkPathCallback chunkPath;

  /// [http.Client.send] `path` used on status
  final StatusPathCallback statusPath;

  /// [http.Client.send] `headers` used on presentation
  final Map<String, String>? presentHeaders;

  /// [http.Client.send] `headers` used on chunk upload
  final RestorableChunkHeadersCallback? chunkHeaders;

  /// [http.Client.send] `headers` used on status
  final StatusHeadersCallback? statusHeaders;

  /// [http.Client.send] `body` used on presentation
  final String? presentBody;

  /// [http.Client.send] `body` used on chunk upload
  final String? chunkBody;

  /// [http.Client.send] `body` used on status
  final String? statusBody;

  /// callback to convert [ResponseType] into [FileUploadPresentationResponse]
  final PresentParser<ResponseType> presentParser;

  /// callback to convert [ResponseType] into [FileUploadStatusResponse]
  final StatusParser<ResponseType> statusParser;

  /// request key for file
  final String fileKey;
}
