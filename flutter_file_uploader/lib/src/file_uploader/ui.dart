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
const _kSpaceBetweenButtonAndFiles = 12.0;

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
  ///
  /// ---
  /// **Controller & External State Management**
  ///
  /// You can provide a [model] (an instance of [FileUploaderModel])
  /// to manage the state externally. This is highly recommended for advanced
  /// use cases like programmatic file additions.
  ///
  /// **Assertion Warning:** You cannot use both a [model] and individual
  /// model properties simultaneously.
  /// If a [model] is provided,
  /// you **must not** pass [onFileAdded], [onPressedAddFiles],
  /// [onFileUploaded], [onFileRemoved], [logger], [limit],
  /// or [transformers] to this widget. Those properties must
  /// be passed directly to the [FileUploaderModel] constructor instead.
  const FileUploader({
    required this.builder,
    super.key,
    this.height = _kButtonHeight,
    this.width = double.maxFinite,
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
    this.transformers,
    this.isDragging = false,
    this.dragPosition,
    this.onFileAdded,
    this.onPressedAddFiles,
    this.model,
  }) : assert(
          model == null ||
              (onFileAdded == null &&
                  onPressedAddFiles == null &&
                  onFileUploaded == null &&
                  onFileRemoved == null &&
                  logger == null &&
                  limit == null &&
                  transformers == null),
          'FileUploader: You cannot provide both a `model` and individual '
          'model properties (limit, logger, callbacks, etc.).\n'
          'If you are providing a model, you must pass these properties '
          'directly to the FileUploaderModel (model) constructor instead.',
        );

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
  final List<FileTransformer>? transformers;

  /// Set to `true` to show the drag effect
  final bool isDragging;

  /// [dragPosition] position of the drag
  ///
  /// this is only used if [isDragging] is true
  final Offset? dragPosition;

  /// external controller, if you want to manage the state outside of the widget
  final FileUploaderModel? model;

  @override
  Widget build(BuildContext context) {
    return _Provider(
      key: const ValueKey('file_uploader_provider'),
      onFileRemoved: onFileRemoved,
      onFileUploaded: onFileUploaded,
      logger: logger,
      limit: limit,
      transformers: transformers,
      onFileAdded: onFileAdded,
      onPressedAddFiles: onPressedAddFiles,
      model: model,
      child: Column(
        children: [
          _builder(context),
          const SizedBox(height: _kSpaceBetweenButtonAndFiles),
          _Button(
            key: const ValueKey('file_uploader_button'),
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
        final onTap = model.onPressedAddFiles();

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

class _Provider extends StatefulWidget {
  const _Provider({
    required this.logger,
    required this.child,
    required this.onFileRemoved,
    required this.onFileUploaded,
    required this.onFileAdded,
    required this.onPressedAddFiles,
    this.limit,
    this.transformers,
    this.model,
    super.key,
  });

  final FileUploaderLogger? logger;
  final Widget child;
  final OnFileUploaded? onFileUploaded;
  final OnFileRemoved? onFileRemoved;
  final OnFileAdded? onFileAdded;
  final OnPressedAddFilesCallback? onPressedAddFiles;
  final int? limit;
  final List<FileTransformer>? transformers;
  final FileUploaderModel? model;

  @override
  State<_Provider> createState() => _ProviderState();
}

class _ProviderState extends State<_Provider> {
  FileUploaderModel? _internalModel;

  FileUploaderModel get _model => widget.model ?? _internalModel!;

  @override
  void initState() {
    super.initState();
    if (widget.model == null) {
      _internalModel = FileUploaderModel(
        logger: widget.logger,
        onFileRemoved: widget.onFileRemoved,
        onFileUploaded: widget.onFileUploaded,
        onFileAdded: widget.onFileAdded,
        onPressedAddFiles: widget.onPressedAddFiles,
        limit: widget.limit,
        transformers: widget.transformers,
      );
    }
  }

  @override
  void didUpdateWidget(covariant _Provider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.model == oldWidget.model) {
      return;
    }

    if (widget.model != null && _internalModel != null) {
      _internalModel!.dispose();
      _internalModel = null;
    } else if (widget.model == null && oldWidget.model != null) {
      _internalModel = FileUploaderModel(
        logger: widget.logger,
        onFileRemoved: widget.onFileRemoved,
        onFileUploaded: widget.onFileUploaded,
        onFileAdded: widget.onFileAdded,
        onPressedAddFiles: widget.onPressedAddFiles,
        limit: widget.limit,
        transformers: widget.transformers,
      );
    }
  }

  @override
  void dispose() {
    _internalModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      child: widget.child,
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
