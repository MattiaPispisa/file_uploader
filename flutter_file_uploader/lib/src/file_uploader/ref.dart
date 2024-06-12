import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter_file_uploader/src/file_uploader/model.dart';

/// A reference to [FileUploaderModel] for those who want to manage file uploads
class FileUploaderRef {
  /// constructor
  FileUploaderRef({
    required this.controller,
    required this.onRemoved,
    required this.onUpload,
  });

  /// controller that handle the file upload and retry
  final FileUploadController controller;

  /// callback to fire on file removed
  final void Function() onRemoved;

  /// callback to fire on file upload
  final void Function(FileUploadResult file) onUpload;
}
