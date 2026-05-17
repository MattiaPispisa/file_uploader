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
///
/// This model has everything needed to [FileCard]
/// to show the file upload state.
/// {@endtemplate}
class FileUploadControllerModel with ChangeNotifier {
  /// {@macro file_upload_controller_model}
  ///
  /// **Constructor**
  ///
  /// [startOnInit] to run the upload immediately
  ///
  /// [progress] to set the initial progress
  ///
  /// [status] to set the initial status
  FileUploadControllerModel({
    required FileUploaderRef ref,
    bool startOnInit = true,
    double progress = 0,
    FileUploadStatus status = FileUploadStatus.waiting,
  })  : _ref = ref,
        _startOnInit = startOnInit,
        _progress = progress.clamp(0, 1),
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
  VoidCallback? uploadCallback() {
    if (!_canUpload()) {
      return null;
    }
    return upload;
  }

  /// return [retry] if is available else null
  VoidCallback? retryCallback() {
    if (!_canUpload()) {
      return null;
    }
    return retry;
  }

  /// callback to remove the file uploaded
  VoidCallback? removeCallback() {
    if (_result == null) {
      return null;
    }

    return _ref.onRemoved;
  }

  /// upload on init
  void _startup() {
    if (!_startOnInit) {
      return;
    }
    upload();
  }

  Future<void> _upload(bool retry) async {
    try {
      if (!_canUpload()) {
        return;
      }

      _initStatus();

      final result = await (retry
          ? _ref.retry(
              onProgress: _updateProgress,
              onTransformationProgress: _updateTransformationProgress,
            )
          : _ref.upload(
              onProgress: _updateProgress,
              onTransformationProgress: _updateTransformationProgress,
            ));
      _status = FileUploadStatus.done;
      _result = result;

      notifyListeners();
    } catch (e) {
      _status = FileUploadStatus.failed;
      notifyListeners();
    }
  }

  void _initStatus() {
    if (_ref.hasTransformers && !_ref.transformersApplied) {
      _status = FileUploadStatus.transforming;
      _transformationProgress = 0;
    } else {
      _status = FileUploadStatus.uploading;
    }

    notifyListeners();
  }

  /// notify upload progress changes
  void _updateProgress(int count, int total) {
    _status = FileUploadStatus.uploading;

    try {
      _progress = count / total;
      notifyListeners();
    } catch (e) {
      // prevent division by zero
    }
  }

  /// Called by the controller during the transformation phase.
  void _updateTransformationProgress(double value) {
    _status = FileUploadStatus.transforming;
    _transformationProgress = value;

    notifyListeners();
  }

  bool _canUpload() {
    return _status == FileUploadStatus.failed ||
        _status == FileUploadStatus.waiting;
  }
}
