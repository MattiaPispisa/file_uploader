import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:en_file_uploader/en_file_uploader.dart';

/// An extension of the [dio.Dio] with methods used by every handlers
/// to execute file upload methods.
///
/// Contains:
///
/// - [sendChunk]
extension DioExtension on dio.Dio {
  /// wrap around [dio.Dio.request] to send
  /// [dio.Dio.request] with [dio.MultipartFile]
  ///
  /// exposing [onProgress] callback
  Future<dio.Response<T>> sendChunk<T>({
    required String method,
    required String path,
    required FileChunk chunk,
    required String fileKey,
    Map<String, String>? headers,
    void Function(int count, int total)? onProgress,
    dio.CancelToken? cancelToken,
  }) {
    final formData = dio.FormData.fromMap({
      fileKey: dio.MultipartFile.fromStream(
        () => chunk.file.openRead(chunk.start, chunk.end),
        chunk.end - chunk.start,
      ),
    });

    return request<T>(
      path,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onProgress,
      options: dio.Options(
        method: method,
        headers: headers,
      ),
    );
  }
}
