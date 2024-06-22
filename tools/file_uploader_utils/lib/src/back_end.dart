import 'dart:typed_data';

/// A memory-based backend that allows inserting files one chunk at a time.
class InMemoryBackend {
  /// Buffer to hold the chunks
  final Map<String, List<Uint8List>> _files = {};

  // prepare the incoming chunks
  String handleIncomingFile() {
    final id = DateTime.now().toIso8601String();
    _files.putIfAbsent(id, () => <Uint8List>[]);
    return id;
  }

  /// return the next chunk offset
  int nextFileOffset(String fileId) {
    if (!_files.containsKey(fileId)) {
      throw Exception('File not found');
    }
    return _files[fileId]!.length;
  }

  /// add a new chunk
  void addChunk(String fileId, Uint8List chunk) {
    if (!_files.containsKey(fileId)) {
      throw Exception('File not found');
    }
    _files[fileId]!.add(chunk);
  }

  /// clear the database
  void clear() {
    _files.clear();
  }

  /// string the files backend
  @override
  String toString() {
    final buffer = StringBuffer();

    for (final fileEntry in _files.entries) {
      buffer.writeln(
        "file: ${fileEntry.key} with ${fileEntry.value.length} chunks uploaded",
      );
    }

    return buffer.toString();
  }
}
