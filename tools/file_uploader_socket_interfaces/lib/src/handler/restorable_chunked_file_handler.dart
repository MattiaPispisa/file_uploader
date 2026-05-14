import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart';
import 'package:file_uploader_socket_interfaces/src/default.dart';

/// {@template socket_restorable_chunked_file_handler}
/// A common interface for any plugin that wants to handle
/// file uploads using a socket client.
/// {@endtemplate}
abstract class SocketRestorableChunkedFileHandler<ResponseType>
    extends RestorableChunkedFileUploadHandler {
  /// {@macro socket_restorable_chunked_file_handler}
  /// 
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
  const SocketRestorableChunkedFileHandler({
    required super.file,
    required this.presentPath,
    required this.chunkPath,
    required this.statusPath,
    required this.presentParser,
    required this.statusParser,
    super.chunkSize,
    this.presentMethod = kPresentMethod,
    this.chunkMethod = kChunkMethod,
    this.statusMethod = kStatusMethod,
    this.presentHeaders,
    this.presentHeadersCallback,
    this.chunkHeaders,
    this.statusHeaders,
    this.presentBody,
    this.chunkBody,
    this.statusBody,
    this.fileKey = kFileKey,
    this.chunkParser = kChunkParser,
  });

  /// `method` used on presentation
  final String presentMethod;

  /// `method` used on chunk upload
  final String chunkMethod;

  /// `method` used on status
  final String statusMethod;

  /// `path` used on presentation
  final String presentPath;

  /// `path` used on chunk upload
  final ChunkPathCallback chunkPath;

  /// `path` used on status
  final StatusPathCallback statusPath;

  /// `headers` used on presentation
  final Map<String, String>? presentHeaders;

  /// `headers` used on presentation
  final PresentHeadersCallback? presentHeadersCallback;

  /// `headers` used on chunk upload
  final RestorableChunkHeadersCallback? chunkHeaders;

  /// `headers` used on status
  final StatusHeadersCallback? statusHeaders;

  /// `body` used on presentation
  final String? presentBody;

  /// `body` used on chunk upload
  final String? chunkBody;

  /// `body` used on status
  final String? statusBody;

  /// callback to convert [ResponseType] into [FileUploadPresentationResponse]
  final PresentParser<ResponseType> presentParser;

  /// callback to validate chunk upload
  final ChunkParser<ResponseType> chunkParser;

  /// callback to convert [ResponseType] into [FileUploadStatusResponse]
  final StatusParser<ResponseType> statusParser;

  /// request key for file
  final String fileKey;
}
