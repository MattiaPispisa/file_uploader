import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:test/test.dart';

/// Create a [XFile] and a [FileUploadController]
/// by passing in a [IFileUploadHandler].
///
/// Ensure the [FileUploadController] functions correctly using:
/// - [Robot.expectUpload]
/// - [Robot.expectRetry]
/// - [Robot.expectUploadError]
/// - [Robot.expectFileUploaderExceptionOnSecondUpload]
class Robot {
  Robot();

  late XFile _file;
  final List<FileTransformer> _transformers = [];
  late FileUploadController _controller;
  FileUploaderLogger? logger;

  /// create a [XFile] of [length]
  void createFile({
    int length = 1024,
  }) {
    _file = utils.createFile(length: length);
  }

  void addTransformer(FileTransformer Function() transformer) {
    _transformers.add(transformer());
  }

  /// Create a [FileUploadController] using [handler]
  void createController(IFileUploadHandler Function(XFile file) handler) {
    _controller = FileUploadController(
      handler(_file),
      transformers: _transformers,
      logger: logger,
    );
  }

  /// Call [FileUploadController.upload] expecting returnsNormally
  Future<void> expectUpload({
    ProgressCallback? onProgress,
    TransformationProgressCallback? onTransformationProgress,
  }) async {
    await _controller.upload(
      onProgress: onProgress,
      onTransformationProgress: onTransformationProgress,
    );

    expect(_controller.uploaded, true);
    expect(
      () {},
      returnsNormally,
    );
  }

  /// Call [FileUploadController.retry] expecting returnsNormally
  Future<void> expectRetry({
    ProgressCallback? onProgress,
    TransformationProgressCallback? onTransformationProgress,
  }) async {
    await _controller.retry(
      onProgress: onProgress,
      onTransformationProgress: onTransformationProgress,
    );

    expect(_controller.uploaded, true);
    expect(
      () {},
      returnsNormally,
    );
  }

  /// Call [FileUploadController.upload] expecting an upload error
  Future<void> expectUploadError<T>() async {
    await expectLater(
      _controller.upload(),
      throwsA(isA<T>()),
    );
    expect(_controller.uploaded, false);
  }

  /// Call [FileUploadController.upload] expecting that file is already
  /// uploaded.
  Future<void> expectFileUploaderExceptionOnSecondUpload() async {
    await expectLater(
      _controller.upload(),
      throwsA(isA<FileAlreadyUploadedException>()),
    );
    expect(_controller.uploaded, true);
  }

  void expectHasTransformers() {
    expect(_controller.hasTransformers, isTrue);
  }

  void expectHasNoTransformers() {
    expect(_controller.hasTransformers, isFalse);
  }

  void expectTransformersApplied() {
    expect(_controller.transformersApplied, isTrue);
  }

  void expectTransformersNotApplied() {
    expect(_controller.transformersApplied, isFalse);
  }

  void dispose() {}
}
