import 'dart:io';
import 'dart:math' as math;

import 'package:file_uploader/file_uploader.dart';
import 'package:file_uploader/src/config.dart';
import 'package:file_uploader/src/entity/entity.dart';
import 'package:file_uploader/src/handler/handler.dart';

part '_chunked_file_upload_controller.dart';
part '_file_upload_controller.dart';
part '_restorable_chunked_file_upload_controller.dart';

typedef ProgressCallback = void Function(int progress, int total);

abstract class FileUploadController {
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

  Future<void> upload({
    ProgressCallback? onProgress,
  });
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
  final effectiveFileSize = await file.length();
  final effectiveChunksCount = math.min(
    effectiveFileSize,
    chunkSize ?? defaultChunkSize,
  );
  int getChunkStart(int chunkIndex) => chunkIndex * effectiveChunksCount;

  int getChunkEnd(int chunkIndex) =>
      math.min((chunkIndex + 1) * effectiveFileSize, effectiveChunksCount);

  for (var i = 0; i < effectiveChunksCount; i++) {
    if (startFrom >= i) {
      await chunkCallback(
        FileChunk(
          file: file,
          start: getChunkStart(i),
          end: getChunkEnd(i),
        ),
        i,
      );
    }
  }

  return;
}
