import 'dart:math' as math;
import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader/src/file_uploader/model.dart';

class FileUploadControllerModel with ChangeNotifier {
  FileUploadControllerModel({
    required FileUploaderRef ref,
    bool startOnInit = true,
    double progress = 0,
    FileCardSemantic semantic = FileCardSemantic.waiting,
  })  : _ref = ref,
        _startOnInit = startOnInit,
        _progress = math.min(progress, 1.0),
        _semantic = semantic {
    _startup();
  }

  final FileUploaderRef _ref;
  final bool _startOnInit;

  double _progress;
  double get progress => _progress;

  FileCardSemantic _semantic;
  FileCardSemantic get semantic => _semantic;

  FileUploadResult? _result;

  void upload() {
    _upload(false);
  }

  void retry() {
    _upload(true);
  }

  void Function()? uploadCallback() {
    if (!_canUpload()) {
      return null;
    }
    return upload;
  }

  void Function()? retryCallback() {
    if (!_canUpload()) {
      return null;
    }
    return retry;
  }

  void Function()? removeCallback() {
    if (_result == null) {
      return null;
    }
    return () {
      _ref.onRemoved();
    };
  }

  void _startup() {
    if (!_startOnInit) {
      return;
    }
    upload();
  }

  void _updateProgress(int count, int total) {
    try {
      _progress = count / total;
      notifyListeners();
    } catch (e) {
      // prevent division by zero
    }
  }

  void _upload(bool retry) async {
    try {
      if (!_canUpload()) {
        return;
      }

      _semantic = FileCardSemantic.uploading;
      final result = await (retry
          ? _ref.controller.retry(onProgress: _updateProgress)
          : _ref.controller.upload(onProgress: _updateProgress));
      _semantic = FileCardSemantic.done;
      _result = result;
      _ref.onUpload(result);
      notifyListeners();
    } catch (e) {
      _semantic = FileCardSemantic.failed;
      notifyListeners();
    }
  }

  bool _canUpload() {
    return _semantic == FileCardSemantic.failed ||
        _semantic == FileCardSemantic.waiting;
  }
}
