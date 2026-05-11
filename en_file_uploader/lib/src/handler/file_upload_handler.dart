import 'package:en_file_uploader/en_file_uploader.dart';

/// {@template file_upload_handler}
/// [FileUploadHandler] handle the upload of an entire file
///
/// ## How to use
///
/// Extends this class to implement the upload of an entire file.
/// ```dart
/// class MyFileUploadHandler extends FileUploadHandler {
///   MyFileUploadHandler({required super.file});
/// }
/// ```
/// Attach the handler to a [FileUploadController] to upload the file.
///
/// ```dart
/// final controller = FileUploadController(MyFileUploadHandler(file: file));
/// controller.upload();
/// ```
/// {@endtemplate}
abstract class FileUploadHandler extends IFileUploadHandler {
  /// {@macro file_upload_handler}
  /// 
  /// **Constructor**
  ///
  /// [file] is the file to upload
  const FileUploadHandler({
    required super.file,
  });

  /// Method for uploading the entire file.
  ///
  /// [onProgress] is a callback that will be called
  /// with the progress of the upload. The callback
  /// will receive the current progress
  /// and the total size of the file.
  ///
  /// ```dart
  /// controller.upload(onProgress: (progress, total) {
  ///   print('Upload progress: $progress of $total');
  /// });
  /// ```
  Future<void> upload(
    XFile file, {
    ProgressCallback? onProgress,
  });
}
