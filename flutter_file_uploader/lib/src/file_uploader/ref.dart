import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader/src/file_uploader/model.dart';

/// A reference to [FileUploaderModel] for those who want to manage file uploads
///
/// ## Example
/// Use [FileUploaderRef] inside a Widget
/// ```dart
/// class MyFile extends StatelessWidget {
///   final FileUploaderRef ref;
///
///    void _onPressedUploadButton() {
///      ref.upload();
///    }
///
///   void _onPressedRetryButton() {
///     ref.retry();
///   }
///
///   Widget build() {
///     ...
///   }
///
/// }
/// ```
///
/// For an out-of-the-box usage use [ProvidedFileCard]
class FileUploaderRef {
  /// constructor
  FileUploaderRef({
    required FileUploadController controller,
    required void Function(FileUploadResult file) onUpload,
    required this.onRemoved,
  })  : _controller = controller,
        _onUpload = onUpload;

  final FileUploadController _controller;
  final void Function(FileUploadResult file) _onUpload;

  /// controller that handle the file upload and retry
  @Deprecated(
    '''
    do not used, 
    instead of `controller.upload` and `onUpload` call `upload`
    instead of `controller.retry` and `onUpload` call `retry`
    
    In the future `controller` will be private
    ''',
  )
  FileUploadController get controller => _controller;

  /// callback to fire on file upload
  @Deprecated('do not use, in the future `onUpload` will be private')
  void Function(FileUploadResult file) get onUpload => _onUpload;

  /// callback to fire on file removed
  final void Function() onRemoved;

  /// upload file
  Future<FileUploadResult> upload({ProgressCallback? onProgress}) async {
    final result = await _controller.upload(onProgress: onProgress);
    _onUpload(result);
    return result;
  }

  /// retry upload file
  Future<FileUploadResult> retry({ProgressCallback? onProgress}) async {
    final result = await _controller.retry(onProgress: onProgress);
    _onUpload(result);
    return result;
  }

  /// return true if the file has already been uploaded.
  /// A file that has been uploaded cannot be uploaded again.
  bool get uploaded => _controller.uploaded;
}
