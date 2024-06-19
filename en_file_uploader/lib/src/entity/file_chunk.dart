import 'package:en_file_uploader/en_file_uploader.dart';

/// Represents a chunk of the file.
class FileChunk {
  /// constructor
  const FileChunk({
    required this.file,
    required this.start,
    required this.end,
  });

  /// The file from which the chunk was taken.
  final XFile file;

  /// The byte from which the chunk starts.
  final int start;

  /// The byte at which the chunk ends.
  final int end;
}
