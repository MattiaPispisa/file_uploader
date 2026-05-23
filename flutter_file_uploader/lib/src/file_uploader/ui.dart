import 'dart:async';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader/src/_constants.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart' as mobkit;
import 'package:provider/provider.dart';

const _kAnimationDuration = Duration(milliseconds: 250);
const _kDragCircleSize = 100.0;
const _kAddDraggedItemIconSize = 30.0;
const _kDragPulseDuration = Duration(milliseconds: 1500);
final _kDragPulseTween = Tween<double>(begin: 0.8, end: 1.2);
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

/// {@template file_uploader}
/// A button that handles file uploads.
/// {@endtemplate}
class FileUploader extends StatelessWidget {
  /// {@macro file_uploader}
  ///
  /// **Constructor**
  ///
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
  ///
  /// use [transformers] to apply a pipeline of [FileTransformer]s to every
  /// file before it is uploaded.
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
    this.loadingColor,
    this.transformers = const [],
    this.isDragging = false,
    this.dragPosition,
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

  /// color of loading progress indicator when [loadingBuilder] is null
  /// and default loading is used
  final Color? loadingColor;

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

  /// transformers applied to every file before upload.
  ///
  /// Each [FileTransformer] is applied in order before the upload starts.
  final List<FileTransformer> transformers;

  /// Set to `true` to show the drag effect
  final bool isDragging;

  /// [dragPosition] position of the drag
  ///
  /// this is only used if [isDragging] is true
  final Offset? dragPosition;

  @override
  Widget build(BuildContext context) {
    return _Provider(
      key: const ValueKey('file_uploader_provider'),
      onFileRemoved: onFileRemoved,
      onFileUploaded: onFileUploaded,
      logger: logger,
      limit: limit,
      transformers: transformers,
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
            loadingColor: loadingColor,
            color: color,
            dragPosition: dragPosition,
            isDragging: isDragging,
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

class _Button extends StatefulWidget {
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
    required this.loadingColor,
    this.isDragging = false,
    this.dragPosition,
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
  final Color? loadingColor;
  final bool isDragging;
  final Offset? dragPosition;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: _kDragPulseDuration,
    );

    _pulseAnimation = _kDragPulseTween.animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _Button oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_handleDragEffect(oldWidget));
  }

  Future<void> _handleDragEffect(covariant _Button oldWidget) async {
    if (widget.isDragging && !_pulseController.isAnimating) {
      await _pulseController.repeat(reverse: true);
    } else if (!widget.isDragging && _pulseController.isAnimating) {
      _pulseController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius =
        widget.borderRadius ?? BorderRadius.circular(kFileUploaderRadius);
    final baseColor = widget.color ?? Theme.of(context).colorScheme.secondary;

    return FileUploaderConsumer(
      key: const ValueKey('file_uploader_button_builder'),
      builder: (context, model, _) {
        final onTap = model.onPressedAddFiles(
          onFileAdded: widget.onFileAdded,
          onPressedAddFiles: widget.onPressedAddFiles,
        );

        final dynamicColor = widget.isDragging
            ? baseColor
            : (model.reachedLimit
                ? baseColor.withValues(alpha: 0.3)
                : baseColor);

        final border = widget.border ??
            mobkit.DashedBorder.all(
              dashLength: 10,
              color: dynamicColor,
            );

        final hide = model.reachedLimit && (widget.hideOnLimit ?? false);

        return AnimatedSwitcher(
          duration: _kAnimationDuration,
          child: hide
              ? const SizedBox()
              : InkWell(
                  key: const ValueKey('file_uploader_button_inkwell'),
                  onTap: onTap,
                  radius: kFileUploaderRadius,
                  hoverColor: baseColor.withValues(alpha: 0.1),
                  focusColor: baseColor.withValues(alpha: 0.1),
                  splashColor: baseColor.withValues(alpha: 0.1),
                  highlightColor: baseColor.withValues(alpha: 0.2),
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: Container(
                      width: widget.width,
                      height: widget.height,
                      decoration: BoxDecoration(
                        border: border,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _content(context, model),
                          ),
                          if (widget.isDragging)
                            Positioned.fill(
                              child: Container(
                                color: baseColor.withValues(alpha: 0.05),
                              ),
                            ),
                          if (widget.isDragging && widget.dragPosition != null)
                            _draggedItemWidget(
                              context,
                              dragPosition: widget.dragPosition!,
                              baseColor: baseColor,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _draggedItemWidget(
    BuildContext context, {
    required Offset dragPosition,
    required Color baseColor,
  }) {
    return Positioned(
      key: const ValueKey('file_uploader_dragged_item_positioned'),
      left: dragPosition.dx - _kDragCircleSize / 2,
      top: dragPosition.dy - _kDragCircleSize / 2,
      child: IgnorePointer(
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            key: const ValueKey('file_uploader_dragged_item_container'),
            width: _kDragCircleSize,
            height: _kDragCircleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: baseColor.withValues(alpha: 0.5),
                width: 2,
              ),
              color: baseColor.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.add,
                color: baseColor,
                size: _kAddDraggedItemIconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, FileUploaderModel model) {
    if (model.processingFiles) {
      return _Loading(
        key: const ValueKey('file_uploader_loading'),
        loading: widget.loadingBuilder?.call(context),
        loadingColor: widget.loadingColor,
      );
    }

    if (model.errorOnFiles != null) {
      return _Error(
        key: const ValueKey('file_uploader_error'),
        error: widget.errorBuilder?.call(context, model.errorOnFiles) ??
            const SizedBox(),
      );
    }

    return _Placeholder(
      key: const ValueKey('file_uploader_placeholder'),
      placeholder: widget.placeholder,
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
    this.transformers = const [],
    super.key,
  });

  final FileUploaderLogger? logger;
  final Widget child;
  final OnFileUploaded? onFileUploaded;
  final OnFileRemoved? onFileRemoved;
  final int? limit;
  final List<FileTransformer> transformers;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FileUploaderModel(
        logger: logger,
        onFileRemoved: onFileRemoved,
        onFileUploaded: onFileUploaded,
        limit: limit,
        transformers: transformers,
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
    required this.loadingColor,
    super.key,
  });

  final Widget? loading;
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: loading ?? CircularProgressIndicator(color: loadingColor),
    );
  }
}
