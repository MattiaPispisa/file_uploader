/// A `en_file_uploader` plugin to handle via `dio` the file upload.
library dio_file_uploader;

export 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart'
    hide ChunkParser, PresentParser, StatusParser;

export 'src/chunked_file_handler.dart';
export 'src/file_handler.dart';
export 'src/restorable_chunked_file_handler.dart';
