import 'dart:math' as math;
import 'package:file_uploader/file_uploader.dart';

/// contains every global option for file upload
class _FileUploaderConfiguration {
  _FileUploaderConfiguration();

  /// default chunk size
  int defaultChunkSize = 1024 * 1024;
}

/// private config exposed with global method
final _config = _FileUploaderConfiguration();

/// to set the default chunk size used by
/// [ChunkedFileUploadHandler] and [RestorableChunkedFileUploadHandler]
void setDefaultChunkSize(int chunkSize) =>
    _config.defaultChunkSize = math.max(chunkSize, 1);

/// get the default chunk size. Can be set with [setDefaultChunkSize]
int get defaultChunkSize => _config.defaultChunkSize;
