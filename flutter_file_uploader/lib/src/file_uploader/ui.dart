import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader/src/_constants.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:provider/provider.dart';

const _kAnimationDuration = Duration(milliseconds: 250);
const _kButtonHeight = 100.0;
const _kBuilderGap = 4.0;

/// on pressed add files, more on [FileUploader]
typedef OnPressedAddFilesCallback = Future<List<XFile>> Function();

/// on file added, more on [FileUploader]
typedef OnFileAdded = Future<IFileUploadHandler> Function(XFile file);

/// builder, more on [FileUploader]
typedef FileUploaderBuilderCallback = Widget Function(
  BuildContext context,
  FileUploaderRef controller,
);

/// on file uploaded, more on [FileUploader]
typedef OnFileUploaded = void Function(FileUploadResult file);

/// on file removed, more on [FileUploader]
typedef OnFileRemoved = void Function(FileUploadResult file);

/// A button that handles file uploads.
class FileUploader extends StatelessWidget {
  /// Upon tapping, the [onPressedAddFiles] function is triggered,
  /// and then [onFileAdded] is called for each file.
  ///
  /// Use the [builder] to create handlers that will upload the files.
  ///
  /// The callbacks [onFileUploaded] and [onFileRemoved] will be executed when
  /// any handler created in the builder uploads or removes a file.
  ///
  /// The [gap] is the space between the elements created with the builder.
  ///
  /// The [placeholder] is the text to display in the center of the button.
  ///
  /// [border], [borderRadius], [height], [width]
  /// are used to customize the button's style.
  ///
  /// use [loadingBuilder] to customize the loading widget
  ///
  /// use [errorBuilder] to customize the error widget
  ///
  /// set either [onPressedAddFiles] or [onFileAdded] to disable the `onTap`
  ///
  /// use [color] to customize [border] color and tap effects.
  const FileUploader({
    required this.builder,
    super.key,
    this.height = _kButtonHeight,
    this.width = double.maxFinite,
    this.onFileAdded,
    this.onPressedAddFiles,
    this.placeholder,
    this.border,
    this.borderRadius,
    this.logger,
    this.gap = _kBuilderGap,
    this.onFileRemoved,
    this.onFileUploaded,
    this.limit,
    this.errorBuilder,
    this.loadingBuilder,
    this.hideOnLimit,
    this.color,
  });

  /// height of the button
  final double height;

  /// width of the button
  final double width;

  /// callback fired when [FileUploader] is tapped
  final OnPressedAddFilesCallback? onPressedAddFiles;

  /// after [onPressedAddFiles] for every file the [onFileAdded] is called
  final OnFileAdded? onFileAdded;

  /// every time a file is uploaded
  final OnFileUploaded? onFileUploaded;

  /// every time a file is removed
  final OnFileRemoved? onFileRemoved;

  /// child of [FileUploader] when is waiting files
  ///
  /// inside you can use [FileUploaderSelector] and [FileUploaderConsumer]
  /// to interact with [FileUploaderModel].
  final Widget? placeholder;

  /// child of [FileUploader] when some files went in error under processing
  ///
  /// inside you can use [FileUploaderSelector] and [FileUploaderConsumer]
  /// to interact with [FileUploaderModel].
  final Widget Function(
    BuildContext context,
    dynamic errorOnFiles,
  )? errorBuilder;

  /// child of [FileUploader] under processing
  ///
  /// default is [CircularProgressIndicator]
  ///
  /// inside you can use [FileUploaderSelector] and [FileUploaderConsumer]
  /// to interact with [FileUploaderModel].
  final Widget Function(
    BuildContext context,
  )? loadingBuilder;

  /// border radius of [FileUploader]
  final BorderRadiusGeometry? borderRadius;

  /// border of [FileUploader]
  final BoxBorder? border;

  /// used to create the file upload handler
  ///
  /// inside you can use [FileUploaderSelector] and [FileUploaderConsumer]
  /// to interact with [FileUploaderModel].
  final FileUploaderBuilderCallback builder;

  /// logger
  final FileUploaderLogger? logger;

  /// gap between [builder] widgets
  final double gap;

  /// maximum number of files that can be uploaded
  final int? limit;

  /// hide file uploader button on limit reached
  final bool? hideOnLimit;

  /// [FileUploader] color used on default [border] and tap effects.
  ///
  /// default is [ColorScheme.secondary].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _Provider(
      key: const ValueKey('file_uploader_provider'),
      onFileRemoved: onFileRemoved,
      onFileUploaded: onFileUploaded,
      logger: logger,
      limit: limit,
      child: Column(
        children: [
          _builder(context),
          const SizedBox(height: 12),
          _Button(
            key: const ValueKey('file_uploader_button'),
            onFileAdded: onFileAdded,
            onPressedAddFiles: onPressedAddFiles,
            border: border,
            width: width,
            height: height,
            borderRadius: borderRadius,
            loadingBuilder: loadingBuilder,
            errorBuilder: errorBuilder,
            placeholder: placeholder,
            hideOnLimit: hideOnLimit,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _builder(BuildContext context) {
    return FileUploaderSelector(
      selector: (_, model) => model.refs,
      builder: (context, refs, _) {
        return Column(
          children: refs
              .map(
                (ref) => Padding(
                  padding: EdgeInsets.only(top: gap),
                  child: builder(context, ref),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.onFileAdded,
    required this.onPressedAddFiles,
    required this.border,
    required this.width,
    required this.height,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.placeholder,
    required this.borderRadius,
    required this.hideOnLimit,
    required this.color,
    super.key,
  });

  final OnFileAdded? onFileAdded;
  final OnPressedAddFilesCallback? onPressedAddFiles;
  final BoxBorder? border;
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, dynamic errorOnFiles)?
      errorBuilder;
  final Widget? placeholder;
  final bool? hideOnLimit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final borderRadius =
        this.borderRadius ?? BorderRadius.circular(kFileUploaderRadius);
    final color = this.color ?? Theme.of(context).colorScheme.secondary;

    return FileUploaderConsumer(
      key: const ValueKey('file_uploader_button_builder'),
      builder: (context, model, _) {
        final onTap = model.onPressedAddFiles(
          onFileAdded: onFileAdded,
          onPressedAddFiles: onPressedAddFiles,
        );
        final border = this.border ??
            DashedBorder.all(
              dashLength: 10,
              color: model.reachedLimit ? color.withOpacity(0.3) : color,
            );
        final hide = model.reachedLimit && (hideOnLimit ?? false);

        return AnimatedSwitcher(
          duration: _kAnimationDuration,
          child: hide
              ? const SizedBox()
              : InkWell(
                  key: const ValueKey('file_uploader_button_inkwell'),
                  onTap: onTap,
                  radius: kFileUploaderRadius,
                  hoverColor: color.withOpacity(0.1),
                  focusColor: color.withOpacity(0.1),
                  splashColor: color.withOpacity(0.1),
                  highlightColor: color.withOpacity(0.2),
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      border: border,
                      borderRadius: borderRadius,
                    ),
                    child: _content(context, model),
                  ),
                ),
        );
      },
    );
  }

  Widget _content(BuildContext context, FileUploaderModel model) {
    if (model.processingFiles) {
      return _Loading(
        key: const ValueKey('file_uploader_loading'),
        loading: loadingBuilder?.call(context),
      );
    }

    if (model.errorOnFiles != null) {
      return _Error(
        key: const ValueKey('file_uploader_error'),
        error:
            errorBuilder?.call(context, model.errorOnFiles) ?? const SizedBox(),
      );
    }

    return _Placeholder(
      key: const ValueKey('file_uploader_placeholder'),
      placeholder: placeholder,
    );
  }
}

class _Provider extends StatelessWidget {
  const _Provider({
    required this.logger,
    required this.child,
    required this.onFileRemoved,
    required this.onFileUploaded,
    this.limit,
    super.key,
  });

  final FileUploaderLogger? logger;
  final Widget child;
  final OnFileUploaded? onFileUploaded;
  final OnFileRemoved? onFileRemoved;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FileUploaderModel(
        logger: logger,
        onFileRemoved: onFileRemoved,
        onFileUploaded: onFileUploaded,
        limit: limit,
      ),
      child: child,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    this.placeholder,
    super.key,
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
    required this.loading,
    super.key,
  });

  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: loading ?? const CircularProgressIndicator(),
    );
  }
}
