import 'package:flutter/material.dart';

class FileCard extends StatelessWidget {
  const FileCard({
    super.key,
    this.progress = 0.0,
    required this.content,
    this.retryIcon = Icons.rotate_left_rounded,
    this.removeIcon = Icons.delete,
    required this.semantic,
    this.borderRadius,
    this.elevation,
    this.onRemove,
    this.onRetry,
    this.padding = const EdgeInsets.all(8),
    this.progressHeight = 10,
    this.removeColor,
    this.retryColor,
    this.uploadIcon = Icons.upload,
    this.onUpload,
    this.uploadColor,
  });

  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;

  final double? elevation;

  final double progress;
  final double progressHeight;

  final Widget content;

  final IconData uploadIcon;
  final VoidCallback? onUpload;
  final Color? uploadColor;

  final IconData retryIcon;
  final VoidCallback? onRetry;
  final Color? retryColor;

  final IconData removeIcon;
  final VoidCallback? onRemove;
  final Color? removeColor;

  final FileCardSemantic semantic;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(4);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: radius),
      elevation: elevation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: padding,
            child: _FileCardContent(
              content: content,
              removeIcon: removeIcon,
              retryIcon: retryIcon,
              semantic: semantic,
              onRemove: onRemove,
              onRetry: onRetry,
              uploadColor: uploadColor,
              uploadIcon: uploadIcon,
              onUpload: onUpload,
              removeColor: removeColor,
              retryColor: retryColor,
            ),
          ),
          _FileCardProgress(
            radius: radius,
            progress: progress,
            height: progressHeight,
          ),
        ],
      ),
    );
  }
}

class _FileCardContent extends StatelessWidget {
  const _FileCardContent({
    required this.content,
    required this.uploadIcon,
    this.onUpload,
    required this.uploadColor,
    required this.retryIcon,
    this.onRetry,
    this.retryColor,
    required this.removeIcon,
    this.onRemove,
    this.removeColor,
    required this.semantic,
  }) : super(key: const ValueKey("_FileCardContent"));

  final Widget content;

  final IconData uploadIcon;
  final VoidCallback? onUpload;
  final Color? uploadColor;

  final IconData retryIcon;
  final VoidCallback? onRetry;
  final Color? retryColor;

  final IconData removeIcon;
  final VoidCallback? onRemove;
  final Color? removeColor;

  final FileCardSemantic semantic;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        content,
        _action(context),
      ],
    );
  }

  Widget _action(BuildContext context) {
    final theme = Theme.of(context);

    if (semantic._showRemove) {
      return _FileCardButton(
        iconData: removeIcon,
        onPressed: onRemove,
        color: removeColor ?? theme.colorScheme.error,
      );
    }
    if (semantic._showRetry) {
      return _FileCardButton(
        iconData: retryIcon,
        onPressed: onRetry,
        color: retryColor ?? theme.colorScheme.error,
      );
    }
    if (semantic._showUpload) {
      return _FileCardButton(
        iconData: uploadIcon,
        onPressed: onUpload,
        color: uploadColor ?? theme.colorScheme.primary,
      );
    }
    return SizedBox();
  }
}

class _FileCardProgress extends StatefulWidget {
  const _FileCardProgress({
    required this.progress,
    required this.radius,
    required this.height,
  }) : super(key: const ValueKey("_FileCardProgress"));

  final double progress;
  final BorderRadius radius;
  final double height;

  @override
  State<_FileCardProgress> createState() => _FileCardProgressState();
}

class _FileCardProgressState extends State<_FileCardProgress> {
  late double _lastProgress = 0;

  @override
  void initState() {
    _lastProgress = 0;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _FileCardProgress oldWidget) {
    _lastProgress = oldWidget.progress;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 250),
      tween: Tween(begin: _lastProgress, end: widget.progress),
      builder: (context, tweenProgress, child) {
        return LinearProgressIndicator(
          value: tweenProgress,
          minHeight: widget.height,
          backgroundColor: theme.colorScheme.secondary,
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: widget.radius.bottomLeft,
            bottomRight: widget.radius.bottomRight,
          ),
        );
      },
    );
  }
}

class _FileCardButton extends StatelessWidget {
  const _FileCardButton({
    super.key,
    required this.iconData,
    this.onPressed,
    required this.color,
  });

  final IconData iconData;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.outlinedButtonTheme.style ?? ButtonStyle();

    final stateColor = WidgetStatePropertyAll(color);

    return OutlinedButton(
      style: style.copyWith(
        iconColor: stateColor,
        shadowColor: stateColor,
        overlayColor: WidgetStatePropertyAll(
          color.withOpacity(0.1),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: color,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Icon(iconData),
    );
  }
}

enum FileCardSemantic {
  uploading,
  waiting,
  failed,
  done;

  bool get _showRemove => this == FileCardSemantic.done;
  bool get _showRetry => this == FileCardSemantic.failed;
  bool get _showUpload => this == FileCardSemantic.waiting;
  bool get _disabled => this == FileCardSemantic.uploading;
}
