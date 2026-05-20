import 'dart:math' as math;

import 'package:en_file_uploader/en_file_uploader.dart';

part '_chunked_file_upload_controller.dart';
part '_file_upload_controller.dart';
part '_restorable_chunked_file_upload_controller.dart';

/// {@template file_upload_controller}
///
/// ## How to use
/// Create a [FileUploadController] by passing a concrete implementation of
/// [FileUploadHandler]; [ChunkedFileUploadHandler] or
/// [RestorableChunkedFileUploadHandler] as the handler.
///
/// The [FileUploadController] will have the capabilities to
/// upload a file ([FileUploadController.upload])
/// and retry the upload ([FileUploadController.retry]).
///
/// Use [FileUploadController.uploaded] to check if
/// the file has already been uploaded.
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
/// }
/// ```
///
/// ### File Transformation
///
/// You can apply a pipeline of [FileTransformer]s to the file before it is
/// uploaded. This is useful for tasks such as image compression or
/// adding metadata.
///
/// Transformers are executed in order. The output of one transformer is
/// passed as the input to the next.
///
/// The final transformed file is cached after the first successful
/// transformation. Subsequent calls to [upload] or [retry] will use the
/// cached file unless the controller is recreated.
///
/// Use [transformersApplied] to check if the transformation phase has
/// completed.
///
/// ```dart
/// final controller = FileUploadController(
///   handler,
///   transformers: [MyTransformer()],
/// );
///
/// await controller.upload(
///   onTransformationProgress: (progress) {
///     // Handle transformation progress (0.0 to 1.0)
///   },
///   onProgress: (sent, total) {
///     // Handle upload progress
///   },
/// );
/// ```
///
/// {@endtemplate}
abstract class FileUploadController {
  /// {@macro file_upload_controller}
  ///
  /// **Constructor**
  ///
  /// [handler] is the handler that will be used to upload the file.
  ///
  /// [handler] must be a concrete implementation of [FileUploadHandler],
  /// [ChunkedFileUploadHandler] or [RestorableChunkedFileUploadHandler]
  /// else an [UnexpectedHandlerException] is thrown.
  ///
  /// [logger] a logger report info/warning/errors about upload behavior.
  ///
  /// [transformers] an optional list of [FileTransformer] that will be applied
  /// to the file before it is uploaded.
  ///
  factory FileUploadController(
    IFileUploadHandler handler, {
    FileUploaderLogger? logger,
    List<FileTransformer> transformers = const [],
  }) {
    if (handler is FileUploadHandler) {
      return _FileUploadController(
        handler: handler,
        logger: logger,
        transformers: transformers,
      );
    }
    if (handler is ChunkedFileUploadHandler) {
      return _ChunkedFileUploadController(
        handler: handler,
        logger: logger,
        transformers: transformers,
      );
    }
    if (handler is RestorableChunkedFileUploadHandler) {
      return _RestorableChunkedFileUploadController(
        handler: handler,
        logger: logger,
        transformers: transformers,
      );
    }

    throw UnexpectedHandlerException(handler: handler);
  }

  FileUploadController._(
    this._transformers,
    this._logger,
  );

  final List<FileTransformer> _transformers;
  final FileUploaderLogger? _logger;

  bool _uploaded = false;

  final List<Future<void> Function()> _cleanupTasks = [];
  XFile? _transformedFile;

  /// Returns `true` if this controller has at least one [FileTransformer].
  bool get hasTransformers => _transformers.isNotEmpty;

  bool _transformersApplied = false;

  /// Returns `true` once the transformers have been applied
  /// (i.e. the transformed file is cached and ready for upload/retry).
  bool get transformersApplied => _transformersApplied;

  /// The handler used by this controller.
  IFileUploadHandler get _handler;

  /// The original file that is being uploaded.
  XFile get originalFile => _handler.originalFile;


  Future<XFile> _applyTransformers({
    required IFileUploadHandler handler,
    TransformationProgressCallback? onTransformationProgress,
  }) async {
    if (_transformers.isEmpty) {
      return handler.originalFile;
    }
    if (_transformersApplied && _transformedFile != null) {
      return _transformedFile!;
    }

    var currentFile = handler.originalFile;
    var currentProgress = 0.0;

    _logger?.info('applying transformers to ${currentFile.path}');
    final totalTransformers = _transformers.length;

    onTransformationProgress?.call(currentProgress);

    for (var i = 0; i < totalTransformers; i++) {
      final transformer = _transformers[i];
      try {
        final transformedFile = await transformer.transform(
          currentFile,
          onProgress: (count) {
            if (onTransformationProgress != null) {
              currentProgress = _roundTo(
                (i + count.clamp(0, 1)) / totalTransformers,
                to: 2,
              );
              onTransformationProgress(currentProgress);
            }
          },
        );

        if (transformedFile.path != currentFile.path) {
          // If the transformer created a new file, we register it for cleanup
          _cleanupTasks.add(() => transformer.cleanup(transformedFile));
        }

        currentFile = transformedFile;
      } catch (error, stackTrace) {
        if (transformer.continueOnFailure) {
          _logger?.warning(
            'Transformer ${transformer.runtimeType} failed '
            'on ${currentFile.path}, continuing with previous file'
            '\n$error\n$stackTrace',
          );
        } else {
          _logger?.error(
            'Transformer ${transformer.runtimeType} failed '
            'on ${currentFile.path}, process is interrupted',
            error,
            stackTrace,
          );
          rethrow;
        }
      }
    }

    if (currentProgress < 1) {
      // ensure always end at 1
      onTransformationProgress?.call(1);
    }

    _transformedFile = currentFile;
    _transformersApplied = true;
    return currentFile;
  }

  /// Clean up the transformed files created during the pipeline.
  Future<void> _cleanupTransformedFiles() async {
    for (final cleanupTask in _cleanupTasks) {
      try {
        await cleanupTask();
      } catch (e, s) {
        _logger?.warning('Something went wrong during files cleanup\n$e\n$s');
      }
    }
    _cleanupTasks.clear();
    _transformedFile = null;
  }

  /// return `true` if the file has already been uploaded.
  ///
  /// A file that has been uploaded cannot be uploaded again
  /// else an [FileAlreadyUploadedException] is thrown.
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
  ///
  /// use [onTransformationProgress] to check the transformation progress
  ///
  /// if the file has already been uploaded,
  /// an [FileAlreadyUploadedException] is thrown.
  ///
  /// ```dart
  /// controller.upload(
  ///   onProgress: (progress, total) {
  ///     print('Upload progress: $progress of $total');
  ///   },
  /// );
  /// ```
  Future<FileUploadResult> upload({
    ProgressCallback? onProgress,
    TransformationProgressCallback? onTransformationProgress,
  });

  /// retry the file upload
  ///
  /// use [onProgress] to check the upload progress
  ///
  /// use [onTransformationProgress] to check the transformation progress
  ///
  /// if the file has been already uploaded,
  /// an [FileAlreadyUploadedException] is thrown.
  ///
  /// ```dart
  /// controller.retry(
  ///   onProgress: (progress, total) {
  ///     print('Upload progress: $progress of $total');
  ///   },
  /// );
  /// ```
  Future<FileUploadResult> retry({
    ProgressCallback? onProgress,
    TransformationProgressCallback? onTransformationProgress,
  });
}

Future<void> _chunksIterator(
  XFile file, {
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

double _roundTo(double value, {required int to}) {
  return double.parse(value.toStringAsFixed(2));
}
