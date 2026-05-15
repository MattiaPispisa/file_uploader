import 'dart:math' as math;
import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

/// {@template file_upload_controller_model}
/// The model that manages the upload state of a file. State is composed of:
///
/// - [FileUploadControllerModel.progress], track the file upload progress
/// - [FileUploadControllerModel.transformationProgress], track the file
///   transformation progress
/// - [FileUploadControllerModel.status], file upload status
///
/// Expose [uploadCallback] and [retryCallback] to run the file upload.
/// [upload] and [retry] run the same functions as
/// [uploadCallback] and [retryCallback]
/// {@endtemplate}
class FileUploadControllerModel with ChangeNotifier {
  /// {@macro file_upload_controller_model}
  ///
  /// **Constructor**
  ///
  /// [startOnInit] to run the upload immediately
  FileUploadControllerModel({
    required FileUploaderRef ref,
    bool startOnInit = true,
    double progress = 0,
    FileUploadStatus status = FileUploadStatus.waiting,
  })  : _ref = ref,
        _startOnInit = startOnInit,
        _progress = math.min(progress, 1),
        _transformationProgress = 0,
        _status = status {
    _startup();
  }

  final FileUploaderRef _ref;
  final bool _startOnInit;

  double _progress;

  /// file upload progress (0..1)
  double get progress => _progress;

  double _transformationProgress;

  /// file transformation progress (0..1).
  ///
  /// Only meaningful while [status] is [FileUploadStatus.transforming].
  double get transformationProgress => _transformationProgress;

  FileUploadStatus _status;

  /// file upload status
  FileUploadStatus get status => _status;

  FileUploadResult? _result;

  /// upload the file
  void upload() {
    _upload(false);
  }

  /// retry the file upload
  void retry() {
    _upload(true);
  }

  /// return [upload] if is available else null
  void Function()? uploadCallback() {
    if (!_canUpload()) {
      return null;
    }
    return upload;
  }

  /// return [retry] if is available else null
  void Function()? retryCallback() {
    if (!_canUpload()) {
      return null;
    }
    return retry;
  }

  /// callback to remove the file uploaded
  void Function()? removeCallback() {
    if (_result == null) {
      return null;
    }

    // ignore: unnecessary_lambdas
    return () => _ref.onRemoved();
  }

  /// upload on init
  void _startup() {
    if (!_startOnInit) {
      return;
    }
    upload();
  }

  /// notify upload progress changes
  void _updateProgress(int count, int total) {
    try {
      _progress = count / total;
      notifyListeners();
    } catch (e) {
      // prevent division by zero
    }
  }

  /// notify transformation progress changes
  void _updateTransformationProgress(double value) {
    _transformationProgress = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> _upload(bool retry) async {
    try {
      if (!_canUpload()) {
        return;
      }

      // If the ref has transformers and they haven't been applied yet,
      // start in the `transforming` state. Otherwise go straight to uploading.
      if (_ref.hasTransformers && !_ref.transformersApplied) {
        _status = FileUploadStatus.transforming;
        _transformationProgress = 0;
        notifyListeners();
      } else {
        _status = FileUploadStatus.uploading;
        notifyListeners();
      }

      final result = await (retry
          ? _ref.retry(
              onProgress: _updateProgress,
              onTransformationProgress: _onTransformationProgress,
            )
          : _ref.upload(
              onProgress: _updateProgress,
              onTransformationProgress: _onTransformationProgress,
            ));
      _status = FileUploadStatus.done;
      _result = result;

      notifyListeners();
    } catch (e) {
      _status = FileUploadStatus.failed;
      notifyListeners();
    }
  }

  /// Called by the controller during the transformation phase.
  void _onTransformationProgress(double value) {
    if (_status != FileUploadStatus.transforming) {
      // Switch to transforming state if we are not already there
      _status = FileUploadStatus.transforming;
    }
    _transformationProgress = value.clamp(0.0, 1.0);

    // When transformation completes (value == 1.0), switch to uploading
    if (_transformationProgress >= 1.0) {
      _status = FileUploadStatus.uploading;
      _transformationProgress = 0;
    }
    notifyListeners();
  }

  bool _canUpload() {
    return _status == FileUploadStatus.failed ||
        _status == FileUploadStatus.waiting;
  }
}
