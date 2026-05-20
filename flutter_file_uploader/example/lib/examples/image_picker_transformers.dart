import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader_example/common/banner.dart';
import 'package:flutter_file_uploader_example/common/view_layout.dart';
import 'package:flutter_file_uploader_example/handlers/handlers.dart';

class CompleteUploadExample extends StatelessWidget {
  const CompleteUploadExample({super.key});

  Future<List<XFile>> _pickFiles() async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.any,
      withData: true,
    );
    if (result == null) {
      return [];
    }

    return result.xFiles;
  }

  Future<IFileUploadHandler> _onFileAdded(XFile file) async {
    return FakeFileHandler(file: file);
  }

  @override
  Widget build(BuildContext context) {
    return ViewLayout(
      title: 'IMAGE PICKER',
      childrenBuilder: (settings) {
        return [
          ExampleBanner(
            title: "Image Picker with transformers",
            description: "desc",
          ),
          Center(
            child: FileUploader(
              logger: utils.fileUploaderLogger,
              limit: settings.limit,
              hideOnLimit: settings.hideOnLimit,
              color: settings.color,
              loadingColor: settings.color,
              transformers: [
                utils.FileImageTransformer(),
              ],
              builder: (context, ref) {
                return ProvidedFileCard(
                  ref: ref,
                  content: ref,
                  uploadProgressColor: settings.color,
                  transformationProgressColor: settings.color,
                );
              },
              onPressedAddFiles: _pickFiles,
              onFileAdded: _onFileAdded,
              onFileUploaded: (file) {
                utils.logger.info("file uploaded ${file.id}");
              },
              onFileRemoved: (file) {
                utils.logger.info("file removed ${file.id}");
              },
              placeholder: Text("add a file"),
            ),
          ),
        ];
      },
    );
  }
}
