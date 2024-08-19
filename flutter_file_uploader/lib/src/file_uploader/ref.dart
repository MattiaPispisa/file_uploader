import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter_file_uploader/src/file_uploader/model.dart';

/// A reference to [FileUploaderModel] for those who want to manage file uploads
class FileUploaderRef {
  /// constructor
  FileUploaderRef({
    required this.controller,
    required this.onUpload,
    required this.onRemoved,
  });

  /// controller that handle the file upload and retry
  @Deprecated(
    '''
    do not used, 
    instead of `controller.upload` and `onUpload` call `upload`
    instead of `controller.retry` and `onUpload` call `retry`
    
    In the future `controller` will be private
    ''',
  )
  final FileUploadController controller;

  /// callback to fire on file upload
  @Deprecated('do not use, in the future `onUpload` will be private')
  final void Function(FileUploadResult file) onUpload;

  /// callback to fire on file removed
  final void Function() onRemoved;

  /// upload file
  Future<FileUploadResult> upload({ProgressCallback? onProgress}) async {
    final result = await controller.upload(onProgress: onProgress);
    onUpload(result);
    return result;
  }

  /// retry upload file
  Future<FileUploadResult> retry({ProgressCallback? onProgress}) async {
    final result = await controller.retry(onProgress: onProgress);
    onUpload(result);
    return result;
  }
}
