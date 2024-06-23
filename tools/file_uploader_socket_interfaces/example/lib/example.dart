import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;

main() async {
  final file = utils.createIoFile();

  final restorableHandler = ImplSocketFileHandler(
    path: 'fake',
    file: XFile(file.path),
  );

  final controller = FileUploadController(
    restorableHandler,
    logger: utils.PrintLogger(),
  );
  await controller.upload();

  print("done!");
}

class ImplSocketFileHandler extends SocketFileHandler<Object> {
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
  Future<void> upload({ProgressCallback? onProgress}) {
    return Future.delayed(const Duration(seconds: 1));
  }
}
