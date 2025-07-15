import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:en_file_uploader/en_file_uploader.dart';

/// create a [File]
File createIoFile({
  String fileName = 'file.txt',
  int length = 1024,
}) {
  final tempDir = Directory.systemTemp.createTempSync();
  final path = '${tempDir.path}/$fileName';
  final file = File(path);

  final random = Random();
  final buffer = List<int>.generate(length, (_) => random.nextInt(256));
  file.writeAsBytesSync(buffer);

  return file;
}

/// create an [XFile] using `dart:io`
XFile createFile({
  String fileName = 'file.txt',
  int length = 1024,
}) {
  final file = createIoFile(fileName: fileName, length: length);
  return XFile(file.path);
}

XFile createBrokenFile() {
  return _BrokenXFile();
}

// Mock XFile class that throws an error when openRead() is called
class _BrokenXFile extends XFile {
  _BrokenXFile() : super('broken_file_path');

  @override
  Stream<Uint8List> openRead([int? start, int? end]) {
    // Return a stream that emits an error
    return Stream.fromFuture(Future.error(Exception('File read error')));
  }

  @override
  Future<int> length() async => 1024; // Return a fake length
}
