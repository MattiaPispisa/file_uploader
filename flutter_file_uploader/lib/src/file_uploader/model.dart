import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

/// The model that manages file uploads and removals.
class FileUploaderModel with ChangeNotifier {
  /// The model that manages file uploads and removals.
  FileUploaderModel({
    FileUploaderLogger? logger,
    OnFileUploaded? onFileUploaded,
    OnFileRemoved? onFileRemoved,
    this.limit,
  })  : _processingFiles = false,
        _controllers = const <FileUploadController>[],
        _logger = logger,
        _filesUploaded = {},
        _errorOnFiles = null,
        _onFileUploaded = onFileUploaded,
        _onFileRemoved = onFileRemoved;

  bool _processingFiles;

  /// true if there are files under processing
  bool get processingFiles => _processingFiles;

  String? _errorOnFiles;

  /// null: no error present
  ///
  /// else: the error string
  String? get errorOnFiles => _errorOnFiles;

  final OnFileUploaded? _onFileUploaded;
  final OnFileRemoved? _onFileRemoved;

  List<FileUploadController> _controllers;

  /// The references to be used by the widgets that handle file uploads:
  Iterable<FileUploaderRef> get refs {
    return _controllers.map(_fileUploaderRefBuilder);
  }

  /// preserve files uploaded
  final Map<FileUploadController, FileUploadResult> _filesUploaded;

  /// logger
  final FileUploaderLogger? _logger;

  /// maximum number of files that can be uploaded
  final int? limit;

  /// Returns the callback to execute when you want to handle a set of files.
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

    if (limit != null && _controllers.length >= limit!) {
      return null;
    }

    return () async {
      try {
        _setProcessing();

        final files = await onPressedAddFiles();
        final controllers = <FileUploadController>[];

        await Future.forEach(files, (file) async {
          controllers.add(_controllerBuilder(await onFileAdded(file)));
        });

        _setStopProcessing(controllers);
      } catch (e, stackTrace) {
        _setErrorOnProcessing(e, stackTrace);
      }
    };
  }

  /// remove [FileUploadController] from [_controllers] and
  ///
  /// remove [FileUploadResult] from [_filesUploaded]
  ///
  /// call [_onFileRemoved]
  void _onRemoved(FileUploadController controller) {
    final file = _filesUploaded[controller];
    if (file == null) {
      return;
    }

    _controllers = [..._controllers]..remove(controller);
    _filesUploaded.remove(controller);
    _onFileRemoved?.call(file);
    notifyListeners();
  }

  /// add [FileUploadResult] to [_filesUploaded]
  ///
  /// call [_onFileUploaded]
  void _onUploaded(FileUploadController controller, FileUploadResult result) {
    _filesUploaded.putIfAbsent(controller, () => result);
    _onFileUploaded?.call(result);
    notifyListeners();
  }

  /// [FileUploadController] builder
  FileUploadController _controllerBuilder(IFileUploadHandler handler) {
    return FileUploadController(handler, logger: _logger);
  }

  /// [FileUploaderRef] builder
  FileUploaderRef _fileUploaderRefBuilder(FileUploadController controller) {
    return FileUploaderRef(
      controller: controller,
      onRemoved: () => _onRemoved(controller),
      onUpload: (result) => _onUploaded(controller, result),
    );
  }

  /// start processing
  void _setProcessing() {
    _processingFiles = true;
    notifyListeners();
  }

  /// stop processing (controllers are available)
  void _setStopProcessing(List<FileUploadController> controllers) {
    _processingFiles = false;
    _controllers = [..._controllers, ...controllers];
    notifyListeners();
  }

  /// set error
  void _setErrorOnProcessing(dynamic e, dynamic stackTrace) {
    _processingFiles = false;
    _errorOnFiles = e.toString();
    _logger?.error(e.toString(), e, stackTrace);
    notifyListeners();
  }
}
