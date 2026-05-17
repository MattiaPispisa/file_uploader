import 'package:en_file_uploader/en_file_uploader.dart';

class NoOpTransformer extends FileTransformer {
  NoOpTransformer({
    this.continueOnFailure = true,
  });

  @override
  final bool continueOnFailure;

  @override
  Future<XFile> transform(
    XFile file, {
    TransformationProgressCallback? onProgress,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    onProgress?.call(0.5);
    await Future.delayed(const Duration(seconds: 1));
    return file;
  }
}
