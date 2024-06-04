/// The response of the file presentation.
class FileUploadStatusResponse {
  /// constructor
  const FileUploadStatusResponse({
    required this.nextChunkOffset,
  });

  /// offset of the next chunk to be sent
  final int nextChunkOffset;
}
