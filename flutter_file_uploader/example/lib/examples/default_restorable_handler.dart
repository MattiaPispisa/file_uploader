import 'package:example/handlers/handlers.dart';
import 'package:example/settings/read.dart';
import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

/// [FileUploader] and [ProvidedFileCard]
/// with [InMemoryRestorableChunkedFileUploadHandler].
class DefaultRestorableChunkedFilesUpload extends StatelessWidget {
  const DefaultRestorableChunkedFilesUpload({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watchSettings();

    return Scaffold(
      appBar: AppBar(
        title: Text('DEFAULT RESTORABLE CHUNKED'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: FileUploader(
                  limit: settings.limit,
                  hideOnLimit: settings.hideOnLimit,
                  color: settings.color,
                  builder: (context, ref) {
                    return ProvidedFileCard(
                      ref: ref,
                      content: Text("filename"),
                    );
                  },
                  onPressedAddFiles: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    return [createFile()];
                  },
                  onFileAdded: (file) async {
                    await Future.delayed(const Duration(milliseconds: 500));
                    return InMemoryRestorableChunkedFileUploadHandler(
                      file: file,
                    );
                  },
                  onFileUploaded: (file) {
                    print("file uploaded ${file.id}");
                  },
                  onFileRemoved: (file) {
                    print("file removed ${file.id}");
                  },
                  placeholder: Text("add a file"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
