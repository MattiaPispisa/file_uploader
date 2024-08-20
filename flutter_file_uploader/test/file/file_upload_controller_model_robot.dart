import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFileUploaderRef extends Mock implements FileUploaderRef {}

class MockCallbackFunction extends Mock {
  void call();
}

class FileUploadControllerModelRobot {
  factory FileUploadControllerModelRobot({
    Future<FileUploadResult> Function(Invocation invocation)? onUpload,
    Future<FileUploadResult> Function(Invocation invocation)? onRetry,
    void Function()? onRemoved,
    bool startOnInit = false,
    bool throwErrorOnUpload = false,
  }) {
    final file = createFile();
    final result = FileUploadResult(id: 'id', file: file);

    Future<FileUploadResult> defaultOnUpload(Invocation invocation) {
      final onProgressCallback =
          invocation.namedArguments[const Symbol('onProgress')] as void
              Function(int, int)?;
      onProgressCallback?.call(100, 100);
      return Future.value(result);
    }

    Future<FileUploadResult> defaultOnRetry(Invocation invocation) {
      final onProgressCallback =
          invocation.namedArguments[const Symbol('onProgress')] as void
              Function(int, int)?;
      onProgressCallback?.call(100, 100);
      return Future.value(result);
    }

    void defaultOnRemoved() {}

    final ref = MockFileUploaderRef();
    final modelNotifier = MockCallbackFunction();

    // when
    final whenUpload = when(
      () => ref.upload(onProgress: any(named: 'onProgress')),
    );
    if (throwErrorOnUpload) {
      whenUpload.thenThrow(Exception());
    } else {
      whenUpload.thenAnswer(onUpload ?? defaultOnUpload);
    }
    when(() => ref.retry(onProgress: any(named: 'onProgress')))
        .thenAnswer(onRetry ?? defaultOnRetry);
    when(() => ref.onRemoved).thenReturn(onRemoved ?? defaultOnRemoved);

    final model = FileUploadControllerModel(
      ref: ref,
      startOnInit: startOnInit,
    )..addListener(modelNotifier.call);

    return FileUploadControllerModelRobot._(ref, model, modelNotifier);
  }

  const FileUploadControllerModelRobot._(
    this._ref,
    this._model,
    this._modelNotifier,
  );

  final FileUploaderRef _ref;
  final FileUploadControllerModel _model;
  final MockCallbackFunction _modelNotifier;

  FileUploadControllerModel get model => _model;

  void dispose() {
    _model.dispose();
  }

  void expectChangeNotifierCalled(int number) {
    if (number <= 0) {
      verifyNever(_modelNotifier.call);
      return;
    }
    verify(_modelNotifier.call).called(number);
  }

  void expectCanUpload() {
    expect(_model.uploadCallback(), isNotNull);
  }

  void expectCanNotUpload() {
    expect(_model.uploadCallback(), isNull);
  }

  void expectCanRetry() {
    expect(_model.retryCallback(), isNotNull);
  }

  void expectCanNotRetry() {
    expect(_model.retryCallback(), isNull);
  }

  void expectCanRemove() {
    expect(_model.removeCallback(), isNotNull);
  }

  void expectCanNotRemove() {
    expect(_model.removeCallback(), isNull);
  }

  void expectStatus(FileUploadStatus status) {
    expect(_model.status, status);
  }

  void expectProgress(double progress) {
    expect(_model.progress, progress);
  }

  void expectUploadCompleted() {
    expectStatus(FileUploadStatus.done);
    expectProgress(1);
  }

  void expectUploadCalled([int number = 1]) {
    if (number <= 0) {
      verifyNever(
        () => _ref.upload(
          onProgress: any(named: 'onProgress'),
        ),
      );
      return;
    }
    verify(
      () => _ref.upload(
        onProgress: any(named: 'onProgress'),
      ),
    ).called(number);
  }

  void expectRetryCalled([int number = 1]) {
    if (number <= 0) {
      verifyNever(
        () => _ref.retry(
          onProgress: any(named: 'onProgress'),
        ),
      );
      return;
    }
    verify(
      () => _ref.retry(
        onProgress: any(named: 'onProgress'),
      ),
    ).called(number);
  }

  void expectRemoveCalled([int number = 1]) {
    if (number <= 0) {
      // ignore: unnecessary_lambdas
      verifyNever(() => _ref.onRemoved());

      return;
    }
    // ignore: unnecessary_lambdas
    verify(() => _ref.onRemoved()).called(number);
  }
}
