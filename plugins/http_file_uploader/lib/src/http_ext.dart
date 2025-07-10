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
    final uri = Uri.parse(path);
    final request = http.StreamedRequest(method, uri);

    request.headers.addAll({
      'Content-Type': 'application/octet-stream',
      'Content-Length': (chunk.end - chunk.start).toString(),
      ...(headers ?? {}),
    });

    final fileStream = chunk.file.openRead(chunk.start, chunk.end);
    int bytesSent = 0;
    final totalBytes = chunk.end - chunk.start;

    fileStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (chunk, sink) {
          bytesSent += chunk.length;
          sink.add(chunk);
          onProgress?.call(bytesSent, totalBytes);
        },
      ),
    );

    await request.sink.addStream(fileStream);
    await request.sink.close();

    final streamResponse = await request.send();

    final responseBytes = await streamResponse.stream.toBytes();

    return http.Response.bytes(
      responseBytes,
      streamResponse.statusCode,
      request: streamResponse.request,
      headers: streamResponse.headers,
      isRedirect: streamResponse.isRedirect,
      persistentConnection: streamResponse.persistentConnection,
      reasonPhrase: streamResponse.reasonPhrase,
    );
  }
}
