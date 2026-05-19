import 'dart:math' as math;
import 'package:en_file_uploader/en_file_uploader.dart';

const int _k1MB = 1024 * 1024;

/// Contains every global option for file upload
class _FileUploaderConfiguration {
  _FileUploaderConfiguration();

  /// default chunk size
  int defaultChunkSize = _k1MB;
}

/// private config exposed with global method
final _config = _FileUploaderConfiguration();

/// to set the default chunk size used by
/// [ChunkedFileUploadHandler] and [RestorableChunkedFileUploadHandler]
///
/// default chunk size can be obtained with [defaultChunkSize]
void setDefaultChunkSize(int chunkSize) =>
    _config.defaultChunkSize = math.max(chunkSize, 1);

/// get the default chunk size. Can be set with [setDefaultChunkSize]
///
/// default is 1MB
int get defaultChunkSize => _config.defaultChunkSize;
