import 'dart:io';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/src/_constants.dart';
import 'package:flutter_file_uploader/src/file_uploader/model.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:provider/provider.dart';

typedef OnPressedAddFilesCallback = Future<List<File>> Function();
typedef OnFileAdded = Future<IFileUploadHandler> Function(File file);
typedef FileUploaderBuilderCallback = Widget Function(
    BuildContext context, FileUploadController controller);

class FileUploader extends StatelessWidget {
  const FileUploader({
    super.key,
    this.height = 100,
    this.width = double.maxFinite,
    this.onFileAdded,
    this.onPressedAddFiles,
    this.placeholder,
    this.border,
    this.borderRadius,
    required this.builder,
    this.logger,
    this.gap = 4,
  });

  final double height;
  final double width;
  final OnPressedAddFilesCallback? onPressedAddFiles;
  final OnFileAdded? onFileAdded;
  final Widget? placeholder;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final FileUploaderBuilderCallback builder;
  final FileUploaderLogger? logger;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return _Provider(
      logger: logger,
      child: Column(
        children: [
          _builder(context),
          const SizedBox(height: 12),
          _button(context),
        ],
      ),
    );
  }

  Widget _builder(BuildContext context) {
    return _Selector(
      selector: (_, model) => model.controllers,
      builder: (context, controllers, _) {
        return Column(
          children: controllers
              .map((controller) => Padding(
                    padding: EdgeInsets.only(top: gap),
                    child: builder(context, controller),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _button(BuildContext context) {
    final theme = Theme.of(context);
    final border = this.border ??
        DashedBorder.all(
          dashLength: 10,
          color: theme.colorScheme.secondary,
        );
    final borderRadius =
        this.borderRadius ?? BorderRadius.circular(kFileUploaderRadius);

    return _Selector(
      selector: (context, model) => (model.processingFiles, model.errorOnFiles),
      builder: (context, data, _) {
        final (processingFiles, errorOnFiles) = data;

        return InkWell(
          onTap: context.read<FileUploaderModel>().onPressedAddFiles(
                onFileAdded: onFileAdded,
                onPressedAddFiles: onPressedAddFiles,
              ),
          radius: kFileUploaderRadius,
          hoverColor: theme.colorScheme.secondary.withOpacity(0.1),
          focusColor: theme.colorScheme.secondary.withOpacity(0.1),
          splashColor: theme.colorScheme.secondary.withOpacity(0.1),
          highlightColor: theme.colorScheme.secondary.withOpacity(0.2),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: border,
              borderRadius: borderRadius,
            ),
            child: processingFiles
                ? _Loading(loading: null)
                : errorOnFiles != null
                    ? _Error(
                        error: null,
                      )
                    : _Placeholder(
                        placeholder: placeholder,
                      ),
          ),
        );
      },
    );
  }
}

class _Provider extends StatelessWidget {
  const _Provider({
    super.key,
    required this.logger,
    required this.child,
  });

  final FileUploaderLogger? logger;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FileUploaderModel(
        logger: logger,
      ),
      child: child,
    );
  }
}

class _Selector<T> extends StatelessWidget {
  const _Selector({
    super.key,
    required this.selector,
    required this.builder,
    this.child,
  });

  final T Function(BuildContext context, FileUploaderModel model) selector;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Selector<FileUploaderModel, T>(
      builder: builder,
      selector: selector,
      child: child,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    super.key,
    this.placeholder,
  });

  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: placeholder,
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({
    super.key,
    this.error,
  });

  final Widget? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: error,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({
    super.key,
    required this.loading,
  });

  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: loading ?? CircularProgressIndicator(),
    );
  }
}
