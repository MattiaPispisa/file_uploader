import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:http_file_uploader/src/http_ext.dart';

/// [HttpRestorableChunkedFileHandler] handle the file upload in chunk with
/// the capability to retry the upload from the last chunk sent.
class HttpRestorableChunkedFileHandler
    extends RestorableChunkedFileUploadHandler {
  /// [client] used to upload the file
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
  const HttpRestorableChunkedFileHandler({
    required http.Client client,
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
    super.chunkSize,
  }) : _client = client;

  final http.Client _client;

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

  /// callback to convert [http.Response] into [FileUploadPresentationResponse]
  final PresentParser presentParser;

  /// callback to convert [http.Response] into [FileUploadStatusResponse]
  final StatusParser statusParser;

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
    return _client
        .sendChunk(
          method: chunkMethod,
          path: chunkPath(presentation, chunk),
          chunk: chunk,
          headers: chunkHeaders?.call(presentation, chunk),
          onProgress: onProgress,
        )
        .then((value) => {});
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

/// compose [http.Client.send] upload chunks `headers` from
/// [FileUploadPresentationResponse] and [FileChunk]
typedef RestorableChunkHeadersCallback = Map<String, String> Function(
  FileUploadPresentationResponse presentation,
  FileChunk chunk,
);

/// compose [http.Client.send] status `headers` from
/// [FileUploadPresentationResponse]
typedef StatusHeadersCallback = Map<String, String> Function(
  FileUploadPresentationResponse presentation,
);

/// compose [http.Client.send] upload chunks `path`
/// from on [FileUploadPresentationResponse] and [FileChunk]
typedef ChunkPathCallback = String Function(
  FileUploadPresentationResponse presentation,
  FileChunk chunk,
);

/// compose [http.Client.send] status `path`
/// from on [FileUploadPresentationResponse]
typedef StatusPathCallback = String Function(
  FileUploadPresentationResponse presentation,
);

/// callback to convert [http.Response] into [FileUploadPresentationResponse]
typedef PresentParser = FileUploadPresentationResponse Function(
  http.Response response,
);

/// callback to convert [http.Response] into [FileUploadStatusResponse]
typedef StatusParser = FileUploadStatusResponse Function(
  http.Response response,
);
