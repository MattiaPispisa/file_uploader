import 'package:en_file_uploader/en_file_uploader.dart';

/// {@template file_transformer}
/// An abstract class representing a file transformation step
/// that can be executed before the upload begins.
/// {@endtemplate}
abstract class FileTransformer {
  /// Whether to continue the upload process
  /// if the transformation fails.
  ///
  /// If `true`, failures will be just logged.
  /// If `false`, exceptions will be rethrown.
  bool get continueOnFailure => false;

  /// Transform the given [file].
  ///
  /// You can report the transformation progress using [onProgress].
  Future<XFile> transform(
    XFile file, {
    ProgressCallback? onProgress,
  });

  /// Clean up the transformed [file] when it's no longer needed.
  ///
  /// This is called automatically by the upload controller after a successful
  /// upload, 
  /// or when a temporary file is replaced by subsequent transformations.
  Future<void> cleanup(XFile file) async {}
}
