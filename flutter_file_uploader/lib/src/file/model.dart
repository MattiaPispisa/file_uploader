import 'dart:math' as math;
import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

/// The model that manages the upload state of a file. State is composed of:
///
/// - [FileUploadControllerModel.progress], track the file upload progress
/// - [FileUploadControllerModel.status], file upload status
///
/// Expose [uploadCallback] and [retryCallback] to run the file upload.
/// [upload] and [retry] run the same functions as
/// [uploadCallback] and [retryCallback]
class FileUploadControllerModel with ChangeNotifier {
  /// The model that manages the upload state of a file
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
        _status = status {
    _startup();
  }

  final FileUploaderRef _ref;
  final bool _startOnInit;

  double _progress;

  /// file upload progress
  double get progress => _progress;

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

  Future<void> _upload(bool retry) async {
    try {
      if (!_canUpload()) {
        return;
      }

      _status = FileUploadStatus.uploading;
      notifyListeners();

      final result = await (retry
          ? _ref.retry(onProgress: _updateProgress)
          : _ref.upload(onProgress: _updateProgress));
      _status = FileUploadStatus.done;
      _result = result;

      notifyListeners();
    } catch (e) {
      _status = FileUploadStatus.failed;
      notifyListeners();
    }
  }

  bool _canUpload() {
    return _status == FileUploadStatus.failed ||
        _status == FileUploadStatus.waiting;
  }
}
