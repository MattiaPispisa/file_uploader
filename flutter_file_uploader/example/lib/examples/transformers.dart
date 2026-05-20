import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader_example/handlers/handlers.dart';
import 'package:flutter_file_uploader_example/settings/read.dart';
import 'package:flutter_file_uploader_example/transformers/transformers.dart';

/// The simplest case that uses [FileUploader] and [ProvidedFileCard].
class TransformersFilesUpload extends StatelessWidget {
  const TransformersFilesUpload({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watchSettings();

    return Scaffold(
      appBar: AppBar(
        title: Text('TRANSFORMERS'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: FileUploader(
                    logger: utils.fileUploaderLogger,
                    limit: settings.limit,
                    hideOnLimit: settings.hideOnLimit,
                    color: settings.color,
                    loadingColor: settings.color,
                    transformers: [NoOpTransformer(), NoOpTransformer()],
                    builder: (context, ref) {
                      return ProvidedFileCard(
                        ref: ref,
                        content: Text("filename"),
                        uploadProgressColor: settings.color,
                        transformationProgressColor: settings.color,
                      );
                    },
                    onPressedAddFiles: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      return [utils.createFile()];
                    },
                    onFileAdded: (file) async {
                      await Future.delayed(const Duration(milliseconds: 500));
                      return FakeFileHandler(
                        file: file,
                      );
                    },
                    onFileUploaded: (file) {
                      utils.logger.info("file uploaded ${file.id}");
                    },
                    onFileRemoved: (file) {
                      utils.logger.info("file removed ${file.id}");
                    },
                    placeholder: Text("add a file"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
