import 'package:en_file_uploader/en_file_uploader.dart';

/// wait some milliseconds and call `onProgress`
/// with different `count` to simulate a progression
class FakeFileHandler extends FileUploadHandler {
  FakeFileHandler({required super.file});

  @override
  Future<void> upload({ProgressCallback? onProgress}) async {
    final fileLength = await file.length();
    onProgress?.call(0, fileLength);
    await Future.delayed(const Duration(milliseconds: 200));

    onProgress?.call(fileLength ~/ 3, fileLength);
    await Future.delayed(const Duration(milliseconds: 400));

    onProgress?.call((fileLength * 2) ~/ 3, fileLength);
    await Future.delayed(const Duration(milliseconds: 200));

    onProgress?.call(fileLength, fileLength);
    return;
  }
}
