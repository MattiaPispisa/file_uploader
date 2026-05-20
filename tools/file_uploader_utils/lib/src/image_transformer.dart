import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:image_pipeline/image_pipeline.dart' as ip;

/// [FileTransformer] for images
class FileImageTransformer extends FileTransformer {
  @override
  Future<XFile> transform(
    XFile file, {
    TransformationProgressCallback? onProgress,
  }) async {
    try {
      final result = await ip.ImageTransformer.native().transform(
        await file.readAsBytes(),
        const [
          ip.ResizeOp(maxHeight: 200, maxWidth: 200),
        ],
      );
      return XFile.fromData(
        result.bytes,
        mimeType: result.mimeType,
      );
    } on ip.UnsupportedImageFormatException catch (_) {
      return file;
    }
  }
}
