import 'package:en_file_uploader/en_file_uploader.dart';

/// {@template file_upload_result}
/// the response of a file uploaded
/// {@endtemplate}
class FileUploadResult {
  /// {@macro file_upload_result}
  const FileUploadResult({
    required this.file,
    required this.id,
  });

  /// the original file that was sent.
  /// It may differ from the file that was actually sent
  /// if any transformations have been applied.
  final XFile file;

  /// In the case of a [RestorableChunkedFileUploadHandler] handler,
  /// the id is the one from the presentation call.
  final String id;
}
