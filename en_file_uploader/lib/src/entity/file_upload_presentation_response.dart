/// The response of the file presentation.
class FileUploadPresentationResponse {
  /// constructor
  const FileUploadPresentationResponse({
    required this.id,
  });

  /// The id referenced by the file for chunk upload.
  final String id;
}
