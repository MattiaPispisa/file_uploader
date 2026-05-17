/// {@template file_upload_presentation_response}
/// The response of the file presentation.
/// {@endtemplate}
class FileUploadPresentationResponse {
  /// {@macro file_upload_presentation_response}
  const FileUploadPresentationResponse({
    required this.id,
  });

  /// The id referenced by the file for chunk upload.
  final String id;
}
