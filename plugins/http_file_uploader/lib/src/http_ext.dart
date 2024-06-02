import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_uploader/file_uploader.dart';
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
    Map<String, String>? headers,
    void Function(int count, int total)? onProgress,
  }) {
    final uri = Uri.parse(path);
    final request = http.MultipartRequest(method, uri);

    if (headers != null) {
      request.headers.addAll(headers);
    }

    request.files.add(
      http.MultipartFile(
        'file',
        chunk.file.openRead(chunk.start, chunk.end),
        chunk.end - chunk.start,
      ),
    );

    return send(request).then((streamResponse) async {
      final completer = Completer<Uint8List>();
      final sink = ByteConversionSink.withCallback(
        (bytes) => completer.complete(
          Uint8List.fromList(bytes),
        ),
      );

      var count = 0;
      final length = streamResponse.contentLength;

      streamResponse.stream.listen(
        (sendedChunk) {
          count += sendedChunk.length;
          sink.add(sendedChunk);

          if (length != null) {
            onProgress?.call(count, length);
          }
        },
        onError: completer.completeError,
        onDone: sink.close,
        cancelOnError: true,
      );

      final body = await completer.future;
      return http.Response.bytes(
        body,
        streamResponse.statusCode,
        request: streamResponse.request,
        headers: streamResponse.headers,
        isRedirect: streamResponse.isRedirect,
        persistentConnection: streamResponse.persistentConnection,
        reasonPhrase: streamResponse.reasonPhrase,
      );
    });
  }
}
