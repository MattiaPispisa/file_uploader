import 'package:example/handlers/fake_file_handler.dart';
import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

/// The simplest case that uses [FileUploader] and [ProvidedFileCard].
class DefaultFilesUpload extends StatelessWidget {
  const DefaultFilesUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DEFAULT'),
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
                  limit: 1,
                  hideOnLimit: false,
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
                    return FakeFileHandler(
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
