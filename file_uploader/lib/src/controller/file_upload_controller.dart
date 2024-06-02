import 'dart:io';
import 'dart:math' as math;

import 'package:file_uploader/file_uploader.dart';

part '_chunked_file_upload_controller.dart';
part '_file_upload_controller.dart';
part '_restorable_chunked_file_upload_controller.dart';

/// Create a [FileUploadController] by passing a concrete implementation of
/// [FileUploadHandler]; [ChunkedFileUploadHandler];
/// [RestorableChunkedFileUploadHandler] as the handler.
///
/// The [FileUploadController] will have the capabilities to
/// upload a file ([FileUploadController.upload])
/// and retry the upload ([FileUploadController.retry]).
abstract class FileUploadController {
  /// [handler]
  ///
  /// [logger] a logger report info/errors about upload behavior
  factory FileUploadController(
    IFileUploadHandler handler, {
    FileUploaderLogger? logger,
  }) {
    if (handler is FileUploadHandler) {
      return _FileUploadController(handler: handler, logger: logger);
    }
    if (handler is ChunkedFileUploadHandler) {
      return _ChunkedFileUploadController(handler: handler, logger: logger);
    }
    if (handler is RestorableChunkedFileUploadHandler) {
      return _RestorableChunkedFileUploadController(
        handler: handler,
        logger: logger,
      );
    }

    throw Exception('unexpected handler ${handler.runtimeType}');
  }

  /// upload the file
  ///
  /// use [onProgress] to check the upload progress
  Future<void> upload({
    ProgressCallback? onProgress,
  });

  /// retry the file upload
  ///
  /// use [onProgress] to check the upload progress
  Future<void> retry({
    ProgressCallback? onProgress,
  });
}

Future<void> _chunksIterator(
  File file, {
  required int? chunkSize,
  required Future<void> Function(FileChunk chunk, int index) chunkCallback,
  int startFrom = 0,
}) async {
  // file size
  final effectiveFileSize = await file.length();

  // calculate info for chunk iteration
  final effectiveChunksSize = math.min(
    effectiveFileSize,
    chunkSize ?? defaultChunkSize,
  );
  final chunkCount = (effectiveFileSize / effectiveChunksSize).ceil();

  int getChunkStart(int chunkIndex) => chunkIndex * effectiveChunksSize;

  // min is used for the last chunk if shorter than chunkSize
  int getChunkEnd(int chunkIndex) =>
      math.min((chunkIndex + 1) * effectiveChunksSize, effectiveFileSize);

  await Future.forEach(
    List.generate(chunkCount, (i) => i),
    (i) async {
      /// to skip file chunk. used on retry callback
      if (startFrom > i) {
        return;
      }

      await chunkCallback(
        FileChunk(
          file: file,
          start: getChunkStart(i),
          end: getChunkEnd(i),
        ),
        i,
      );
    },
  );

  return;
}
