import 'dart:io';
import 'dart:math';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:example/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ShowCase(),
    );
  }
}

class ShowCase extends StatelessWidget {
  const ShowCase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    return MockFileHandler(
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

class MockFileHandler extends FileUploadHandler {
  MockFileHandler({required super.file});

  @override
  Future<void> upload({ProgressCallback? onProgress}) async {
    await Future.delayed(const Duration(seconds: 1));
    return;
  }
}

File createFile({
  int length = 1024,
}) {
  final tempDir = Directory.systemTemp.createTempSync();
  final file = File('${tempDir.path}/file.txt');

  final random = Random();
  final buffer = List<int>.generate(length, (_) => random.nextInt(256));
  file.writeAsBytesSync(buffer);
  return file;
}
