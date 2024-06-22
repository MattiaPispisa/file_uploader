/// A `FileUploader` plugin to handle via `http` the file upload.
library http_file_uploader;

export 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart'
    hide PresentParser, StatusParser;

export 'src/chunked_file_handler.dart';
export 'src/file_handler.dart';
export 'src/restorable_chunked_file_handler.dart';
