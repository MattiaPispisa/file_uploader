import 'dart:math' as math;

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

class FileUploadControllerModel with ChangeNotifier {
  FileUploadControllerModel({
    required FileUploadController controller,
    bool startOnInit = true,
    double progress = 0,
    FileCardSemantic semantic = FileCardSemantic.waiting,
  })  : _controller = controller,
        _startOnInit = startOnInit,
        _progress = math.min(progress, 1.0),
        _semantic = semantic {
    _startup();
  }

  final FileUploadController _controller;
  final bool _startOnInit;

  double _progress;
  double get progress => _progress;

  FileCardSemantic _semantic;
  FileCardSemantic get semantic => _semantic;

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
      await retry
          ? _controller.retry(onProgress: _updateProgress)
          : _controller.upload(onProgress: _updateProgress);
      _semantic = FileCardSemantic.done;
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
