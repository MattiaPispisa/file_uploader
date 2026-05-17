import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

/// {@template file_uploader_ref}
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
/// {@endtemplate}
class FileUploaderRef {
  /// {@macro file_uploader_ref}
  ///
  /// **Constructor**
  FileUploaderRef({
    required FileUploadController controller,
    required void Function(FileUploadResult file) onUpload,
    required this.onRemoved,
  })  : _controller = controller,
        _onUpload = onUpload;

  final FileUploadController _controller;
  final void Function(FileUploadResult file) _onUpload;

  /// callback to fire on file removed
  final void Function() onRemoved;

  /// Whether the underlying controller has at least one [FileTransformer].
  ///
  /// Use this to decide whether to show a transformation progress indicator.
  bool get hasTransformers => _controller.hasTransformers;

  /// Whether the transformers have already been applied (result is cached).
  bool get transformersApplied => _controller.transformersApplied;

  /// upload file
  Future<FileUploadResult> upload({
    ProgressCallback? onProgress,
    TransformationProgressCallback? onTransformationProgress,
  }) async {
    final result = await _controller.upload(
      onProgress: onProgress,
      onTransformationProgress: onTransformationProgress,
    );
    _onUpload(result);
    return result;
  }

  /// retry upload file
  Future<FileUploadResult> retry({
    ProgressCallback? onProgress,
    TransformationProgressCallback? onTransformationProgress,
  }) async {
    final result = await _controller.retry(
      onProgress: onProgress,
      onTransformationProgress: onTransformationProgress,
    );
    _onUpload(result);
    return result;
  }

  /// return true if the file has already been uploaded.
  /// A file that has been uploaded cannot be uploaded again.
  bool get uploaded => _controller.uploaded;
}
