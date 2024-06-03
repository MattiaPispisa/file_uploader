import 'dart:io';
import 'package:file_uploader/file_uploader.dart';

/// the response of a file uploaded
class FileUploadResult {
  /// the response of a file uploaded
  const FileUploadResult({
    required this.file,
    required this.id,
  });

  /// file uploaded
  final File file;

  /// In the case of a [RestorableChunkedFileUploadHandler] handler,
  /// the id is the one from the presentation call.
  final String id;
}
