import 'package:flutter/material.dart';
import 'package:flutter_file_uploader_example/settings/model.dart';
import 'package:flutter_file_uploader_example/settings/read.dart';

class ViewLayout extends StatelessWidget {
  const ViewLayout({
    super.key,
    required this.title,
    required this.childrenBuilder,
  });

  final String title;
  final List<Widget> Function(ExampleSettings settings) childrenBuilder;

  @override
  Widget build(BuildContext context) {
    final settings = context.watchSettings();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: childrenBuilder(settings),
          ),
        ),
      ),
    );
  }
}
