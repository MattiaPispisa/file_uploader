import 'package:en_file_uploader/en_file_uploader.dart';

/// compose request upload chunks `headers` from
/// [FileUploadPresentationResponse] and [FileChunk]
typedef RestorableChunkHeadersCallback = Map<String, String> Function(
  FileUploadPresentationResponse presentation,
  FileChunk chunk,
);

/// compose request status `headers` from
/// [FileUploadPresentationResponse]
typedef StatusHeadersCallback = Map<String, String> Function(
  FileUploadPresentationResponse presentation,
);

/// compose request upload chunks `path`
/// from on [FileUploadPresentationResponse] and [FileChunk]
typedef ChunkPathCallback = String Function(
  FileUploadPresentationResponse presentation,
  FileChunk chunk,
);

/// compose request status `path`
/// from on [FileUploadPresentationResponse]
typedef StatusPathCallback = String Function(
  FileUploadPresentationResponse presentation,
);

/// callback to convert response into [FileUploadPresentationResponse]
typedef PresentParser<T> = FileUploadPresentationResponse Function(
  T response,
);

/// callback to convert response into [FileUploadStatusResponse]
typedef StatusParser<T> = FileUploadStatusResponse Function(
  T response,
);
