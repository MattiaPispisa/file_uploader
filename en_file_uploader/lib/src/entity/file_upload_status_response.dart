/// {@template file_upload_status_response}
/// The response of the file presentation.
/// {@endtemplate}
class FileUploadStatusResponse {
  /// {@macro file_upload_status_response}
  const FileUploadStatusResponse({
    required this.nextChunkOffset,
  });

  /// offset of the next chunk to be sent
  final int nextChunkOffset;
}
