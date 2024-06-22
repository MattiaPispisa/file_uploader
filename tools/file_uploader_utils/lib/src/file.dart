import 'dart:io';
import 'dart:math';

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
