import 'dart:io';

class FileChunk {
  const FileChunk({
    required this.file,
    required this.start,
    required this.end,
  });

  final File file;
  final int start;
  final int end;
}
