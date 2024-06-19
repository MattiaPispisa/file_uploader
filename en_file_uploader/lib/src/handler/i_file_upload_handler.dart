import 'package:en_file_uploader/en_file_uploader.dart';

/// The base class from which [FileUploadHandler], [ChunkedFileUploadHandler]
/// and [RestorableChunkedFileUploadHandler] were extended.
///
/// Do not extend [IFileUploadHandler],
/// [FileUploadController] will not handle it!.
abstract class IFileUploadHandler {
  /// constructor
  const IFileUploadHandler({
    required this.file,
  });

  /// file to handle
  final XFile file;
}
