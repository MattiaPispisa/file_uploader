import 'dart:io';

import 'package:http/http.dart';
import 'package:http_file_uploader/http_file_uploader.dart';
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: FileUploader(
                  builder: (context, controller) {
                    return FileCard(
                      content: Text("filename"),
                      progress: 0.3,
                      semantic: FileCardSemantic.waiting,
                      onRemove: () => {},
                    );
                  },
                  onPressedAddFiles: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    return [File("ciao")];
                  },
                  onFileAdded: (file) async {
                    await Future.delayed(const Duration(milliseconds: 500));
                    return HttpFileHandler(
                      path: "aa",
                      file: file,
                      client: Client(),
                    );
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
