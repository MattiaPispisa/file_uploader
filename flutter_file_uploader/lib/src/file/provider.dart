import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/src/file/model.dart';
import 'package:flutter_file_uploader/src/file_uploader/model.dart';
import 'package:provider/provider.dart';

class FileUploadControllerProvider extends StatelessWidget {
  const FileUploadControllerProvider({
    super.key,
    required this.ref,
    required this.child,
  });

  final FileUploaderRef ref;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FileUploadControllerModel(
        ref: ref,
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
