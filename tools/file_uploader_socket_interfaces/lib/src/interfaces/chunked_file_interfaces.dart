import 'package:en_file_uploader/en_file_uploader.dart';

/// compose request `headers` from [FileChunk]
typedef ChunkHeadersCallback = Map<String, String> Function(
  FileChunk chunk,
);
