import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class FileUploadControllerProvider extends StatelessWidget {
  const FileUploadControllerProvider({
    super.key,
    required this.controller,
    required this.child,
  });

  final FileUploadController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FileUploadControllerModel(
        controller: controller,
      ),
      child: child,
    );
  }
}

class FileUploadControllerSelector<T> extends StatelessWidget {
  const FileUploadControllerSelector({
    super.key,
    required this.selector,
    required this.builder,
    this.child,
  });

  final T Function(
    BuildContext context,
    FileUploadControllerModel model,
  ) selector;

  final Widget Function(
    BuildContext context,
    T value,
    Widget? child,
  ) builder;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Selector<FileUploadControllerModel, T>(
      builder: builder,
      selector: selector,
      child: child,
    );
  }
}

class FileUploadControllerConsumer extends StatelessWidget {
  const FileUploadControllerConsumer({
    super.key,
    required this.builder,
    this.child,
  });

  final Widget Function(
    BuildContext context,
    FileUploadControllerModel model,
    Widget? child,
  ) builder;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Consumer<FileUploadControllerModel>(
      builder: builder,
      child: child,
    );
  }
}
