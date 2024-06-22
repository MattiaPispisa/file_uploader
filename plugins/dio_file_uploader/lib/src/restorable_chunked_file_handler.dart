import 'package:dio/dio.dart' as dio;
import 'package:dio_file_uploader/dio_file_uploader.dart';
import 'package:dio_file_uploader/src/dio_ext.dart';
import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart'
    as interfaces;

/// [DioRestorableChunkedFileHandler] handle the file upload in chunk with
/// the capability to retry the upload from the last chunk sent.
class DioRestorableChunkedFileHandler
    extends SocketRestorableChunkedFileHandler<dio.Response<dynamic>> {
  /// [client] used to upload the file
  ///
  /// set [chunkSize] to choose the size of the chunks else
  /// [defaultChunkSize] is used
  const DioRestorableChunkedFileHandler({
    required dio.Dio client,
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
    this.cancelToken,
  }) : _client = client;

  final dio.Dio _client;

  /// Controls cancellation of [dio.Dio]'s requests.
  final dio.CancelToken? cancelToken;

  @override
  Future<FileUploadPresentationResponse> present() {
    return _client
        .request<dynamic>(
          presentPath,
          cancelToken: cancelToken,
          data: presentBody,
          options: dio.Options(
            method: presentMethod,
            headers: presentHeaders,
          ),
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
        .sendChunk<dynamic>(
          method: chunkMethod,
          path: chunkPath(presentation, chunk),
          chunk: chunk,
          headers: chunkHeaders?.call(presentation, chunk),
          onProgress: onProgress,
          fileKey: fileKey,
        )
        .then(chunkParser);
  }

  @override
  Future<FileUploadStatusResponse> status(
    FileUploadPresentationResponse presentation,
  ) {
    return _client
        .request<dynamic>(
          statusPath(presentation),
          cancelToken: cancelToken,
          data: statusBody,
          options: dio.Options(
            method: statusMethod,
            headers: statusHeaders?.call(presentation),
          ),
        )
        .then(statusParser);
  }
}

/// callback to convert [dio.Response] into [FileUploadPresentationResponse]
typedef PresentParser<T> = interfaces.PresentParser<dio.Response<T>>;

/// callback to validate chunk upload
typedef ChunkParser<T> = interfaces.ChunkParser<dio.Response<T>>;

/// callback to convert [dio.Response] into [FileUploadStatusResponse]
typedef StatusParser<T> = interfaces.StatusParser<dio.Response<T>>;
