import 'package:example/handlers/fake_file_handler.dart';
import 'package:example/main.dart';
import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

/// The simplest case that uses [FileUploader] and [ProvidedFileCard].
class SelfRefManagementFilesUpload extends StatelessWidget {
  const SelfRefManagementFilesUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SELF REF MANAGEMENT'),
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
                  builder: (context, ref) {
                    return CustomFileCardSelfManagement(
                      ref: ref,
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

class CustomFileCardSelfManagement extends StatefulWidget {
  const CustomFileCardSelfManagement({
    super.key,
    required this.ref,
  });

  final FileUploaderRef ref;

  @override
  State<CustomFileCardSelfManagement> createState() =>
      _CustomFileCardSelfManagementState();
}

class _CustomFileCardSelfManagementState
    extends State<CustomFileCardSelfManagement> {
  bool uploading = false;
  bool error = false;

  void _upload() async {
    setState(() {
      uploading = true;
    });
    try {
      await widget.ref.upload();
    } catch (e) {
      setState(() {
        error = true;
      });
    } finally {
      setState(() {
        uploading = false;
      });
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ref.uploaded) {
      return Text("file uploaded");
    }

    if (uploading) {
      return CircularProgressIndicator();
    }

    if (error) {
      return Text("error uploading");
    }

    return ElevatedButton(
      onPressed: _upload,
      child: Text("upload"),
    );
  }
}
