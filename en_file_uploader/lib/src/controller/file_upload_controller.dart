import 'dart:io';
import 'dart:math' as math;

import 'package:en_file_uploader/en_file_uploader.dart';

part '_chunked_file_upload_controller.dart';
part '_file_upload_controller.dart';
part '_restorable_chunked_file_upload_controller.dart';

/// ## How to use
/// Create a [FileUploadController] by passing a concrete implementation of
/// [FileUploadHandler]; [ChunkedFileUploadHandler] or
/// [RestorableChunkedFileUploadHandler] as the handler.
///
/// The [FileUploadController] will have the capabilities to
/// upload a file ([FileUploadController.upload])
/// and retry the upload ([FileUploadController.retry]).
///
/// ## Example
///
/// ```dart
/// // a concrete `RestorableChunkedFileUploadHandler` that with [client]
/// // handle implement the file upload methods
/// class RemoteRestorableChunkedFileUploadHandler
///    extends RestorableChunkedFileUploadHandler {
///  RemoteRestorableChunkedFileUploadHandler({
///    required super.file,
///    this.client,
///    super.chunkSize,
///  });
///
///  // an imaginary client that handle:
///  // present, status, uploadChunk
///  final client;
///
///  @override
///  Future<FileUploadPresentationResponse> present() async {
///    return client.presentOnBackend();
///  }
///
///  @override
///  Future<FileUploadStatusResponse> status(
///    FileUploadPresentationResponse presentation,
///  ) async {
///    return client.getBackendStatus(presentation);
///  }
///
///  @override
///  Future<void> uploadChunk(
///    FileUploadPresentationResponse presentation,
///    FileChunk chunk, {
///    ProgressCallback? onProgress,
///  }) async {
///    return client.sendChunkToBackend(presentation, chunk);
///  }
///}
///```

abstract class FileUploadController {
  /// [handler]
  ///
  /// [logger] a logger report info/warning/errors about upload behavior
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

    throw UnexpectedHandlerException(handler: handler);
  }

  FileUploadController._();

  bool _uploaded = false;

  /// return `true` if the file has already been uploaded.
  /// A file that has been uploaded cannot be uploaded again.
  bool get uploaded => _uploaded;

  /// set the file as uploaded
  void _setUploaded() => _uploaded = true;

  /// check if file is not uploaded
  void _ensureNotUploaded() {
    if (!_uploaded) {
      return;
    }
    throw const FileAlreadyUploadedException();
  }

  /// upload the file
  ///
  /// use [onProgress] to check the upload progress
  Future<FileUploadResult> upload({
    ProgressCallback? onProgress,
  });

  /// retry the file upload
  ///
  /// use [onProgress] to check the upload progress
  Future<FileUploadResult> retry({
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

/// now + a random int
String _generateUniqueId() {
  final random = math.Random();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomValue = random.nextInt(100000);
  return '$timestamp$randomValue';
}
