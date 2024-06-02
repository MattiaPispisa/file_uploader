import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_uploader/file_uploader.dart';

final backend = InMemoryBackend();

void main() async {
  backend.clear();

  var sampleFile = createFile(name: "test1", length: 1024);
  var handler = ExampleRestorableChunkedFileUploadHandler(
    file: sampleFile,
    chunkSize: 500,
  );
  var controller = FileUploadController(handler);
  await controller.upload();

  sampleFile = createFile(name: "test2", length: 1024);
  handler = ExampleRestorableChunkedFileUploadHandler(
    file: sampleFile,
    chunkSize: 1000,
  );
  controller = FileUploadController(handler);
  await controller.upload();

  print(backend.toString());
}

/// An example implementation of a [RestorableChunkedFileUploadHandler] handler that sends
/// data to an [InMemoryBackend]
class ExampleRestorableChunkedFileUploadHandler
    extends RestorableChunkedFileUploadHandler {
  ExampleRestorableChunkedFileUploadHandler({
    required super.file,
    super.chunkSize,
  });

  @override
  Future<FileUploadPresentationResponse> present() {
    final id = backend.handleIncomingFile();
    return Future.value(FileUploadPresentationResponse(id: id));
  }

  @override
  Future<FileUploadStatusResponse> status(
    FileUploadPresentationResponse presentation,
  ) {
    final offset = backend.nextFileOffset(presentation.id);
    return Future.value(
      FileUploadStatusResponse(nextChunkOffset: offset),
    );
  }

  @override
  Future<void> uploadChunk(
    FileUploadPresentationResponse presentation,
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) {
    backend.addChunk(
      presentation.id,
      chunk.file.readAsBytesSync().sublist(chunk.start, chunk.end),
    );
    return Future.value();
  }
}

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

/// create a file with [name] with a random content
///
/// file [length]
File createFile({
  required String name,
  int length = 1024,
}) {
  final tempDir = Directory.systemTemp.createTempSync();
  final file = File('${tempDir.path}/$name.txt');

  final random = Random();
  final buffer = List<int>.generate(length, (_) => random.nextInt(256));
  file.writeAsBytesSync(buffer);

  return file;
}
