import 'package:en_file_uploader/en_file_uploader.dart';

/// callback to validate chunk upload
typedef ChunkParser<T> = void Function(
  T response,
);

/// compose request `headers` from [XFile]
typedef FileHeadersCallback = Map<String, String>? Function(
  XFile file,
);
