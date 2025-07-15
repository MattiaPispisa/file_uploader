import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart'
    as interfaces;
import 'package:http/http.dart' as http;
import 'package:http_file_uploader/http_file_uploader.dart';
import 'package:http_file_uploader/src/http_ext.dart';

/// [HttpRestorableChunkedFileHandler] handle the file upload in chunk with
/// the capability to retry the upload from the last chunk sent.
class HttpRestorableChunkedFileHandler
    extends SocketRestorableChunkedFileHandler<http.Response> {
  /// [client] used to upload the file
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
  const HttpRestorableChunkedFileHandler({
    required http.Client client,
    required super.file,
    required super.presentPath,
    required super.chunkPath,
    required super.statusPath,
    required super.presentParser,
    required super.statusParser,
    super.presentMethod,
    super.chunkMethod,
    super.statusMethod,
    super.presentHeaders,
    super.chunkHeaders,
    super.statusHeaders,
    super.presentBody,
    super.chunkBody,
    super.statusBody,
    super.chunkSize,
    super.fileKey,
    super.chunkParser,
    this.streamedRequest = true,
  }) : _client = client;

  final http.Client _client;

  /// if `true` use a [http.StreamedRequest] to upload the chunk
  /// else use a [http.Request].
  ///
  /// default is `true`
  final bool streamedRequest;

  @override
  Future<FileUploadPresentationResponse> present() {
    return _client
        .sendUnStream(
          method: presentMethod,
          path: presentPath,
          body: presentBody,
          headers: presentHeaders,
        )
        .then(presentParser);
  }

  @override
  Future<void> uploadChunk(
    FileUploadPresentationResponse presentation,
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) async {
    if (streamedRequest) {
      return _client
          .sendStreamedChunk(
            method: chunkMethod,
            path: chunkPath(presentation, chunk),
            chunk: chunk,
            fileKey: fileKey,
            headers: chunkHeaders?.call(presentation, chunk),
            onProgress: onProgress,
          )
          .then(chunkParser);
    }
    return _client
        .sendSimpleChunk(
          method: chunkMethod,
          path: chunkPath(presentation, chunk),
          chunk: chunk,
          fileKey: fileKey,
          headers: chunkHeaders?.call(presentation, chunk),
          onProgress: onProgress,
        )
        .then(chunkParser);
  }

  @override
  Future<FileUploadStatusResponse> status(
    FileUploadPresentationResponse presentation,
  ) {
    return _client
        .sendUnStream(
          method: statusMethod,
          path: statusPath(presentation),
          body: statusBody,
          headers: statusHeaders?.call(presentation),
        )
        .then(statusParser);
  }
}

/// callback to convert [http.Response] into [FileUploadPresentationResponse]
typedef PresentParser = interfaces.PresentParser<http.Response>;

/// callback to validate chunk upload
typedef ChunkParser = interfaces.ChunkParser<http.Response>;

/// callback to convert [http.Response] into [FileUploadStatusResponse]
typedef StatusParser = interfaces.StatusParser<http.Response>;
