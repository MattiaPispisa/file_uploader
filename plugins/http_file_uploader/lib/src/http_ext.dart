import 'package:file_uploader/file_uploader.dart';
import 'package:http/http.dart' as http;

extension HttpExtension on http.Client {
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

  Future<http.Response> sendChunk({
    required String method,
    required String path,
    required FileChunk chunk,
    Map<String, String>? headers,
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

    return send(request).then(http.Response.fromStream);
  }
}
