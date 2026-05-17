// ignore_for_file: avoid_print just for example

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;

void main() async {
  final file = utils.createIoFile();

  final restorableHandler = ImplSocketFileHandler(
    path: 'fake',
    file: XFile(file.path),
  );

  final controller = FileUploadController(
    restorableHandler,
    logger: utils.fileUploaderLogger,
  );
  await controller.upload();

  print('done!');
}

/// example implementation of the [SocketFileHandler]
class ImplSocketFileHandler extends SocketFileHandler<Object> {
  /// create an [ImplSocketFileHandler]
  ImplSocketFileHandler({
    required super.file,
    required super.path,
    super.body,
    super.fileKey,
    super.fileParser,
    super.headers,
    super.method,
  });

  @override
  Future<void> upload(XFile file, {ProgressCallback? onProgress}) {
    return Future.delayed(const Duration(seconds: 1));
  }
}
