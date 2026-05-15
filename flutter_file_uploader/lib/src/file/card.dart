import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader/src/_constants.dart';

const _kAnimationDuration = Duration(milliseconds: 300);
const _kFastAnimationDuration = Duration(milliseconds: 150);

/// {@template file_card}
/// An agnostic file upload widget.
///
/// Use [ProvidedFileCard] to build [FileCard] with business logic
/// {@endtemplate}
class FileCard extends StatelessWidget {
  /// {@macro file_card}
  ///
  /// **Constructor**
  const FileCard({
    required this.content,
    required this.status,
    this.progress = 0.0,
    this.transformationProgress = 0.0,
    this.retryIcon = Icons.rotate_left_rounded,
    this.removeIcon = Icons.delete_outline_rounded,
    this.borderRadius,
    this.elevation,
    this.onRemove,
    this.onRetry,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.progressHeight = 4,
    this.removeColor,
    this.retryColor,
    this.uploadIcon = Icons.upload_rounded,
    this.onUpload,
    this.uploadColor,
    this.uploadProgressColor,
    this.transformationProgressColor,
    super.key,
  });

  /// border radius applied on card
  final BorderRadius? borderRadius;

  /// [FileCard.content] padding
  final EdgeInsetsGeometry padding;

  /// card elevation
  final double? elevation;

  /// upload progress (0..1)
  final double progress;

  /// transformation progress (0..1)
  ///
  /// Only shown while [status] is [FileUploadStatus.transforming].
  final double transformationProgress;

  /// height of the progress indicators
  final double progressHeight;

  /// card child
  ///
  /// Starting from the left, it expands up to the call to action.
  ///
  /// Below the content, there is a LinearProgressIndicator.
  final Widget content;

  /// upload button icon
  final IconData uploadIcon;

  /// upload button callback
  final VoidCallback? onUpload;

  /// upload button color
  final Color? uploadColor;

  /// retry button icon
  final IconData retryIcon;

  /// retry button callback
  final VoidCallback? onRetry;

  /// retry button color
  final Color? retryColor;

  /// remove button icon
  final IconData removeIcon;

  /// remove button callback
  final VoidCallback? onRemove;

  /// remove button color
  final Color? removeColor;

  /// upload status
  final FileUploadStatus status;

  /// color of the upload progress bar.
  ///
  /// Defaults to [ColorScheme.primary].
  final Color? uploadProgressColor;

  /// color of the transformation progress bar.
  ///
  /// Defaults to a teal/amber accent distinct from the upload color.
  final Color? transformationProgressColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(kFileUploaderRadius);
    final effectiveUploadColor =
        uploadProgressColor ?? theme.colorScheme.primary;
    final effectiveTransformColor =
        transformationProgressColor ?? theme.colorScheme.tertiary;

    return AnimatedOpacity(
      duration: _kAnimationDuration,
      opacity: status._disabled ? 0.75 : 1,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: radius),
        elevation: elevation ?? 1,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: padding,
              child: _FileCardContent(
                content: content,
                removeIcon: removeIcon,
                retryIcon: retryIcon,
                semantic: status,
                onRemove: onRemove,
                onRetry: onRetry,
                uploadColor: uploadColor,
                uploadIcon: uploadIcon,
                onUpload: onUpload,
                removeColor: removeColor,
                retryColor: retryColor,
              ),
            ),
            _FileCardProgressSection(
              radius: radius,
              status: status,
              progress: progress,
              transformationProgress: transformationProgress,
              height: progressHeight,
              uploadColor: effectiveUploadColor,
              transformColor: effectiveTransformColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _FileCardContent extends StatelessWidget {
  const _FileCardContent({
    required this.content,
    required this.uploadIcon,
    required this.uploadColor,
    required this.retryIcon,
    required this.removeIcon,
    required this.semantic,
    this.onUpload,
    this.onRetry,
    this.retryColor,
    this.onRemove,
    this.removeColor,
  }) : super(key: const ValueKey('_file_card_content'));

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

  final FileUploadStatus semantic;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: content),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: _kAnimationDuration,
          child: _action(context),
        ),
      ],
    );
  }

  Widget _action(BuildContext context) {
    final theme = Theme.of(context);

    if (semantic._showRemove) {
      return _FileCardButton(
        key: const ValueKey('remove_button'),
        iconData: removeIcon,
        onPressed: onRemove,
        color: removeColor ?? theme.colorScheme.error,
      );
    }
    if (semantic._showRetry) {
      return _FileCardButton(
        key: const ValueKey('retry_button'),
        iconData: retryIcon,
        onPressed: onRetry,
        color: retryColor ?? theme.colorScheme.error,
      );
    }
    if (semantic._showUpload) {
      return _FileCardButton(
        key: const ValueKey('upload_button'),
        iconData: uploadIcon,
        onPressed: onUpload,
        color: uploadColor ?? theme.colorScheme.primary,
      );
    }

    // Status indicator while transforming or uploading (no action available)
    return _FileCardButton(
      key: const ValueKey('fake_button'),
      iconData: uploadIcon,
      color: Colors.transparent,
    );
  }
}

/// Shows the dual progress section: transformation bar (if transforming)
/// followed by upload bar (if uploading/done).
class _FileCardProgressSection extends StatelessWidget {
  const _FileCardProgressSection({
    required this.radius,
    required this.status,
    required this.progress,
    required this.transformationProgress,
    required this.height,
    required this.uploadColor,
    required this.transformColor,
  });

  final BorderRadius radius;
  final FileUploadStatus status;
  final double progress;
  final double transformationProgress;
  final double height;
  final Color uploadColor;
  final Color transformColor;

  @override
  Widget build(BuildContext context) {
    final isTransforming = status == FileUploadStatus.transforming;
    final isUploading = status == FileUploadStatus.uploading ||
        status == FileUploadStatus.done;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Transformation progress bar — only visible while transforming
        AnimatedSize(
          duration: _kAnimationDuration,
          curve: Curves.easeInOut,
          child: isTransforming
              ? _FileCardProgress(
                  key: const ValueKey('_file_card_transformation_progress'),
                  progress: transformationProgress,
                  radius: isUploading ? BorderRadius.zero : radius,
                  bottomRadius: isUploading ? BorderRadius.zero : radius,
                  height: height,
                  color: transformColor,
                  backgroundColor:
                      transformColor.withValues(alpha: 0.15),
                )
              : const SizedBox.shrink(),
        ),
        // Upload progress bar — visible while uploading or done
        _FileCardProgress(
          key: const ValueKey('_file_card_progress'),
          progress: isUploading ? progress : 0,
          radius: isTransforming ? BorderRadius.zero : radius,
          bottomRadius: radius,
          height: height,
          color: uploadColor,
          backgroundColor: uploadColor.withValues(alpha: 0.12),
        ),
      ],
    );
  }
}

class _FileCardProgress extends StatefulWidget {
  const _FileCardProgress({
    required this.progress,
    required this.radius,
    required this.bottomRadius,
    required this.height,
    required this.color,
    required this.backgroundColor,
    super.key,
  });

  final double progress;
  final BorderRadius radius;
  final BorderRadius bottomRadius;
  final double height;
  final Color color;
  final Color backgroundColor;

  @override
  State<_FileCardProgress> createState() => _FileCardProgressState();
}

class _FileCardProgressState extends State<_FileCardProgress> {
  late double _lastProgress;

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
    return TweenAnimationBuilder(
      duration: _kAnimationDuration,
      tween: Tween(begin: _lastProgress, end: widget.progress),
      builder: (context, tweenProgress, child) {
        return LinearProgressIndicator(
          value: tweenProgress,
          minHeight: widget.height,
          backgroundColor: widget.backgroundColor,
          color: widget.color,
          borderRadius: BorderRadius.only(
            bottomLeft: widget.bottomRadius.bottomLeft,
            bottomRight: widget.bottomRadius.bottomRight,
          ),
        );
      },
    );
  }
}

class _FileCardButton extends StatelessWidget {
  const _FileCardButton({
    required this.iconData,
    required this.color,
    super.key,
    this.onPressed,
  });

  final IconData iconData;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.outlinedButtonTheme.style ?? const ButtonStyle();

    final stateColor = WidgetStatePropertyAll(color);

    return OutlinedButton(
      style: style.copyWith(
        iconColor: stateColor,
        shadowColor: stateColor,
        overlayColor: WidgetStatePropertyAll(
          color.withValues(alpha: 0.1),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: color),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
      ),
      onPressed: onPressed,
      child: Icon(iconData, size: 18),
    );
  }
}

/// The various states of the upload
enum FileUploadStatus {
  /// waiting to start the upload
  waiting,

  /// file transformation in progress (before upload)
  transforming,

  /// upload in progress
  uploading,

  /// upload failed
  failed,

  /// upload completed
  done;

  bool get _showRemove => this == FileUploadStatus.done;

  bool get _showRetry => this == FileUploadStatus.failed;

  bool get _showUpload => this == FileUploadStatus.waiting;

  bool get _disabled =>
      this == FileUploadStatus.uploading ||
      this == FileUploadStatus.transforming;
}
