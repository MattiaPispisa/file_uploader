import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:en_file_uploader/en_file_uploader.dart';

XFile createFile({
  int length = 1024,
}) {
  return utils.createFile(length: length);
}

/// instance of [utils.InMemoryBackend]
final backend = utils.InMemoryBackend();
