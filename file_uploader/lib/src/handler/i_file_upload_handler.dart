import 'dart:io';

abstract class IFileUploadHandler {
  const IFileUploadHandler({
    required this.file,
  });

  final File file;
}
