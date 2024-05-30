import 'package:file_uploader/file_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:http_file_uploader/src/http_ext.dart';

class HttpRestorableChunkedFileHandler
    extends RestorableChunkedFileUploadHandler {
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

  final String presentMethod;
  final String chunkMethod;
  final String statusMethod;

  final String presentPath;
  final ChunkPathCallback chunkPath;
  final StatusPathCallback statusPath;

  final Map<String, String>? presentHeaders;
  final ChunkHeadersCallback? chunkHeaders;
  final StatusHeadersCallback? statusHeaders;

  final String? presentBody;
  final String? chunkBody;
  final String? statusBody;

  final PresentParser presentParser;
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
    FileChunk chunk,
  ) {
    return _client
        .sendUnStream(
          method: chunkMethod,
          path: chunkPath(presentation),
          body: chunkBody,
          headers: chunkHeaders?.call(presentation, chunk),
        )
        .then((_) => {});
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

typedef ChunkHeadersCallback = Map<String, String> Function(
  FileUploadPresentationResponse presentation,
  FileChunk chunk,
);
typedef StatusHeadersCallback = Map<String, String> Function(
  FileUploadPresentationResponse presentation,
);

typedef ChunkPathCallback = String Function(
  FileUploadPresentationResponse presentation,
);
typedef StatusPathCallback = String Function(
  FileUploadPresentationResponse presentation,
);

typedef PresentParser = FileUploadPresentationResponse Function(http.Response);
typedef StatusParser = FileUploadStatusResponse Function(http.Response);
