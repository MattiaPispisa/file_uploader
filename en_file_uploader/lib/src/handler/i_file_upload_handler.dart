import 'package:en_file_uploader/en_file_uploader.dart';

/// {@template i_file_upload_handler}
/// The base class from which [FileUploadHandler], [ChunkedFileUploadHandler]
/// and [RestorableChunkedFileUploadHandler] were extended.
///
/// Do not extend [IFileUploadHandler],
/// [FileUploadController] will not handle it!.
/// {@endtemplate}
abstract class IFileUploadHandler {
  /// {@macro i_file_upload_handler}
  const IFileUploadHandler({
    required XFile file,
  }) : originalFile = file;

  /// {@macro original_file}
  @Deprecated('instead use originalFile')
  XFile get file => originalFile;

  /// {@template original_file}
  /// The file to upload.
  ///
  /// The file may differ from the one that will be sent
  /// if any transformations have been applied.
  /// {@endtemplate}
  final XFile originalFile;
}
