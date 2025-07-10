import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:http/http.dart' as http;

/// An extension of the [http.Client] with methods used by every handlers
/// to execute file upload methods.
///
/// Contains:
///
/// - [sendUnStream]
/// - [sendChunk]
extension HttpExtension on http.Client {
  /// wrap around [http.Client.send] to send request unStream with
  /// optional parameters
  Future<http.Response> sendUnStream({
    required String method,
    required String path,
    String? body,
    Map<String, String>? headers,
  }) {
    final request = http.Request(method, Uri.parse(path));
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      request.body = body;
    }

    return send(request).then(http.Response.fromStream);
  }

  /// wrap around [http.Client.send] to send [http.MultipartRequest]
  /// exposing [onProgress] callback
  Future<http.Response> sendChunk({
    required String method,
    required String path,
    required FileChunk chunk,
    required String fileKey,
    Map<String, String>? headers,
    void Function(int count, int total)? onProgress,
  }) async {
    var bytesSent = 0;
    final completer = Completer<void>();

    final uri = Uri.parse(path);
    final request = http.StreamedRequest(method, uri);

    request.contentLength = chunk.end - chunk.start;

    request.headers.addAll({
      'Content-Type': 'application/octet-stream',
      ...(headers ?? {}),
    });

    final fileStream = chunk.file.openRead(chunk.start, chunk.end);
    final totalBytes = chunk.end - chunk.start;

    final subscription = fileStream.listen(
      (data) {
        bytesSent += data.length;
        onProgress?.call(bytesSent, totalBytes);
        request.sink.add(data);
      },
      onError: (error, stackTrace) {
        request.sink.addError(error, stackTrace);
        completer.completeError(error, stackTrace);
      },
      onDone: () {
        request.sink.close();
        completer.complete();
      },
      cancelOnError: true,
    );

    try {
      await completer.future;
      return send(request).then(http.Response.fromStream);
    } catch (e) {
      await subscription.cancel();
      rethrow;
    }
  }
}
