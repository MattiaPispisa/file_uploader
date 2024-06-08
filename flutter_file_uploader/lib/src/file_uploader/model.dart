import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';

import 'ui.dart';

class FileUploaderModel with ChangeNotifier {
  FileUploaderModel({
    FileUploaderLogger? logger,
    bool processingFiles = false,
    String? errorOnFiles = null,
    List<FileUploadController> controllers = const <FileUploadController>[],
  })  : _processingFiles = processingFiles,
        _controllers = controllers,
        _logger = logger;

  bool _processingFiles;
  bool get processingFiles => _processingFiles;

  String? _errorOnFiles;
  String? get errorOnFiles => _errorOnFiles;

  List<FileUploadController> _controllers;
  List<FileUploadController> get controllers => _controllers;

  FileUploaderLogger? _logger;

  Future<void> Function()? onPressedAddFiles({
    OnPressedAddFilesCallback? onPressedAddFiles,
    OnFileAdded? onFileAdded,
  }) {
    if (_processingFiles) {
      return null;
    }

    if (onPressedAddFiles == null || onFileAdded == null) {
      return null;
    }

    return () async {
      try {
        _setProcessing();

        final files = await onPressedAddFiles();
        final controllers = <FileUploadController>[];

        await Future.forEach(files, (file) async {
          controllers.add(_controller(await onFileAdded(file)));
        });

        _setStopProcessing(controllers);
      } catch (e, stackTrace) {
        _setErrorOnProcessing(e, stackTrace);
      }
    };
  }

  void onRemovedController(FileUploadController controller) {
    _controllers.remove(controller);
    notifyListeners();
  }

  FileUploadController _controller(IFileUploadHandler handler) {
    return FileUploadController(handler, logger: _logger);
  }

  void _setProcessing() {
    _processingFiles = true;
    notifyListeners();
  }

  void _setStopProcessing(List<FileUploadController> controllers) {
    _processingFiles = false;
    _controllers = [..._controllers, ...controllers];
    notifyListeners();
  }

  void _setErrorOnProcessing(dynamic e, dynamic stackTrace) {
    _processingFiles = false;
    _errorOnFiles = e.toString();
    _logger?.error(e.toString(), e, stackTrace);
    notifyListeners();
  }
}
