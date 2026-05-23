import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

/// {@template file_uploader_model}
/// The model that manages file uploads and removals.
/// {@endtemplate}
class FileUploaderModel with ChangeNotifier {
  /// {@macro file_uploader_model}
  ///
  /// **Constructor**
  FileUploaderModel({
    FileUploaderLogger? logger,
    OnFileUploaded? onFileUploaded,
    OnFileRemoved? onFileRemoved,
    OnFileAdded? onFileAdded,
    OnPressedAddFilesCallback? onPressedAddFiles,
    this.limit,
    List<FileTransformer>? transformers,
  })  : _processingFiles = false,
        _controllers = List<FileUploadController>.unmodifiable([]),
        _logger = logger,
        _filesUploaded = {},
        _errorOnFiles = null,
        _onFileUploaded = onFileUploaded,
        _onFileRemoved = onFileRemoved,
        _transformers = transformers,
        _onFileAdded = onFileAdded,
        _onPressedAddFiles = onPressedAddFiles;

  bool _processingFiles;

  /// true if there are files under processing (during [onPressedAddFiles])
  bool get processingFiles => _processingFiles;

  dynamic _errorOnFiles;

  /// error during [onPressedAddFiles]
  /// null: no error present
  ///
  /// else: the error caught
  dynamic get errorOnFiles => _errorOnFiles;

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

  /// transformers applied to each file before upload
  final List<FileTransformer>? _transformers;

  final OnFileAdded? _onFileAdded;
  final OnPressedAddFilesCallback? _onPressedAddFiles;

  /// files uploaded reach the available limit
  bool get reachedLimit {
    if (limit == null) {
      return false;
    }

    return _controllers.length >= limit!;
  }

  /// add files to be uploaded
  ///
  /// [files] the files to be uploaded
  Future<void> addFiles(List<XFile> files) async {
    if (files.isEmpty || _processingFiles || reachedLimit) {
      return;
    }

    try {
      _setProcessing();

      final controllers = <FileUploadController>[];

      await Future.forEach(files, (file) async {
        final result = await _onFileAdded?.call(file);
        if (result != null) {
          controllers.add(_controllerBuilder(result));
        }
      });

      _setStopProcessing(controllers);
    } catch (e, stackTrace) {
      _setErrorOnProcessing(e, stackTrace);
    }
  }

  /// Returns the callback to execute when you want to handle a set of files.
  Future<void> Function()? onPressedAddFiles() {
    if (_processingFiles ||
        reachedLimit ||
        _onPressedAddFiles == null ||
        _onFileAdded == null) {
      return null;
    }

    return () async {
      try {
        final files = await _onPressedAddFiles?.call();
        await addFiles(files ?? []);
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
    _controllers = List.unmodifiable([..._controllers]..remove(controller));

    final file = _filesUploaded.remove(controller);

    if (file != null) {
      _onFileRemoved?.call(file);
    }

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
    return FileUploadController(
      handler,
      logger: _logger,
      transformers: _transformers ?? [],
    );
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
    _errorOnFiles = null;
    _processingFiles = true;
    notifyListeners();
  }

  /// stop processing (controllers are available)
  void _setStopProcessing(List<FileUploadController> controllers) {
    _processingFiles = false;
    _errorOnFiles = null;
    _controllers = List.unmodifiable([..._controllers, ...controllers]);
    notifyListeners();
  }

  /// set error
  void _setErrorOnProcessing(dynamic e, dynamic stackTrace) {
    _processingFiles = false;
    _errorOnFiles = e;
    _logger?.error(e.toString(), e, stackTrace);
    notifyListeners();
  }
}
