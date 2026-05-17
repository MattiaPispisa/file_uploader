import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader/src/_constants.dart';

const _kAnimationDuration = Duration(milliseconds: 300);
const _kDisabledOpacity = 0.75;
const _kActionSpacing = 8.0;
const _kActionSize = 44.0;
const _kIndicatorPadding = 12.0;
const _kIndicatorStrokeWidth = 2.5;
const _kProgressBackgroundAlpha = 0.15;
const _kOverlayAlpha = 0.1;
const _kIconSize = 18.0;

/// {@template file_card}
/// An agnostic file upload card widget.
///
/// Use [ProvidedFileCard] to build [FileCard]
/// with business logic out-of-the-box.
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
    this.elevation = 1.0,
    this.onRemove,
    this.onRetry,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.progressHeight = 4.0,
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

    // Resolve UI properties, falling back to theme defaults if not provided.
    final radius = borderRadius ?? BorderRadius.circular(kFileUploaderRadius);
    final effectiveUploadColor =
        uploadProgressColor ?? theme.colorScheme.primary;
    final effectiveTransformColor =
        transformationProgressColor ?? theme.colorScheme.tertiary;

    // The entire card visually fades out slightly if the status implies
    // an ongoing, non-interruptible operation (like transforming or uploading).
    return AnimatedOpacity(
      duration: _kAnimationDuration,
      opacity: status._disabled ? _kDisabledOpacity : 1.0,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: radius),
        elevation: elevation,
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
                status: status,
                onRemove: onRemove,
                onRetry: onRetry,
                uploadColor: uploadColor,
                uploadIcon: uploadIcon,
                onUpload: onUpload,
                removeColor: removeColor,
                retryColor: retryColor,
                transformationProgress: transformationProgress,
                transformColor: effectiveTransformColor,
              ),
            ),
            _FileCardProgressSection(
              radius: radius,
              status: status,
              progress: progress,
              height: progressHeight,
              uploadColor: effectiveUploadColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<FileUploadStatus>('status', status))
      ..add(DoubleProperty('progress', progress))
      ..add(DoubleProperty('transformationProgress', transformationProgress))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding))
      ..add(DoubleProperty('elevation', elevation))
      ..add(DoubleProperty('progressHeight', progressHeight))
      ..add(ColorProperty('uploadColor', uploadColor))
      ..add(ColorProperty('uploadProgressColor', uploadProgressColor))
      ..add(
        ColorProperty(
          'transformationProgressColor',
          transformationProgressColor,
        ),
      )
      ..add(ColorProperty('removeColor', removeColor))
      ..add(ColorProperty('retryColor', retryColor))
      ..add(IconDataProperty('uploadIcon', uploadIcon))
      ..add(IconDataProperty('removeIcon', removeIcon))
      ..add(IconDataProperty('retryIcon', retryIcon))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onUpload', onUpload))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onRemove', onRemove))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onRetry', onRetry));
  }
}

/// Builds the main row of the card, containing the user-provided [content]
/// on the left and the contextual action button/indicator on the right.
/// Converted to a StatefulWidget to handle pure-UI animation delays.
class _FileCardContent extends StatefulWidget {
  const _FileCardContent({
    required this.content,
    required this.uploadIcon,
    required this.uploadColor,
    required this.retryIcon,
    required this.removeIcon,
    required this.status,
    required this.transformationProgress,
    required this.transformColor,
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
  final FileUploadStatus status;
  final double transformationProgress;
  final Color transformColor;

  @override
  State<_FileCardContent> createState() => _FileCardContentState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<FileUploadStatus>('semantic', status))
      ..add(DoubleProperty('transformationProgress', transformationProgress))
      ..add(ColorProperty('transformColor', transformColor));
  }
}

class _FileCardContentState extends State<_FileCardContent> {
  // We use local state variables to control what is displayed.
  // This allows us to briefly ignore upstream changes to let animations finish.
  late FileUploadStatus _displaySemantic;
  late double _displayTransformProgress;
  Timer? _uiDelayTimer;

  @override
  void initState() {
    super.initState();
    _displaySemantic = widget.status;
    _displayTransformProgress = widget.transformationProgress;
  }

  @override
  void didUpdateWidget(covariant _FileCardContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the business logic rapidly switches from transforming -> uploading,
    // we want to hold the UI in the 'transforming' state just long enough
    // for the circular progress indicator to animate to 100%.
    if (oldWidget.status == FileUploadStatus.transforming &&
        widget.status == FileUploadStatus.uploading) {
      // Force visual progress to 100% so the circle completes
      _displayTransformProgress = 1.0;

      _uiDelayTimer?.cancel();
      _uiDelayTimer = Timer(_kAnimationDuration, () {
        if (mounted) {
          setState(() {
            // After the timer, sync back with the real business logic state
            _displaySemantic = widget.status;
            _displayTransformProgress = widget.transformationProgress;
          });
        }
      });
    } else {
      // Normal state update
      _uiDelayTimer?.cancel();
      _displaySemantic = widget.status;
      _displayTransformProgress = widget.transformationProgress;
    }
  }

  @override
  void dispose() {
    _uiDelayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // The main content expands to fill available horizontal space.
        Expanded(child: widget.content),
        const SizedBox(width: _kActionSpacing),
        // BLOCCHIAMO l'area dell'azione a 44x44 fissi.
        AnimatedSwitcher(
          duration: _kAnimationDuration,
          child: _action(context),
        ),
      ],
    );
  }

  /// Determines which action widget to display based on the local [_displaySemantic] state.
  Widget _action(BuildContext context) {
    final theme = Theme.of(context);

    if (_displaySemantic._showRemove) {
      return _FileCardButton(
        key: const ValueKey('remove_button'),
        iconData: widget.removeIcon,
        onPressed: widget.onRemove,
        color: widget.removeColor ?? theme.colorScheme.error,
      );
    }
    if (_displaySemantic._showRetry) {
      return _FileCardButton(
        key: const ValueKey('retry_button'),
        iconData: widget.retryIcon,
        onPressed: widget.onRetry,
        color: widget.retryColor ?? theme.colorScheme.error,
      );
    }
    if (_displaySemantic._showUpload) {
      return _FileCardButton(
        key: const ValueKey('upload_button'),
        iconData: widget.uploadIcon,
        onPressed: widget.onUpload,
        color: widget.uploadColor ?? theme.colorScheme.primary,
      );
    }

    // When a local transformation is running, display an animated circular
    // indicator instead of an actionable button.
    if (_displaySemantic == FileUploadStatus.transforming) {
      return SizedBox(
        key: const ValueKey('transforming_indicator'),
        width: _kActionSize,
        height: _kActionSize,
        child: Padding(
          padding: const EdgeInsets.all(_kIndicatorPadding),
          child: _FileCardCircularProgress(
            progress: _displayTransformProgress,
            color: widget.transformColor,
          ),
        ),
      );
    }

    // Render an empty box of the same size to maintain layout constraints
    // while uploading (since the linear bar is active below).
    return const SizedBox(
      key: ValueKey('fake_button'),
      width: _kActionSize,
      height: _kActionSize,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      EnumProperty<FileUploadStatus>('displaySemantic', _displaySemantic),
    );
    properties.add(
      DoubleProperty('displayTransformProgress', _displayTransformProgress),
    );
    properties.add(DiagnosticsProperty<Timer?>('uiDelayTimer', _uiDelayTimer));
  }
}

/// A stateful widget that handles the smooth animation of the circular progress indicator.
class _FileCardCircularProgress extends StatefulWidget {
  const _FileCardCircularProgress({
    required this.progress,
    required this.color,
    super.key,
  });

  final double progress;
  final Color color;

  @override
  State<_FileCardCircularProgress> createState() =>
      _FileCardCircularProgressState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('progress', progress));
    properties.add(ColorProperty('color', color));
  }
}

class _FileCardCircularProgressState extends State<_FileCardCircularProgress> {
  late double _lastProgress;

  @override
  void initState() {
    _lastProgress = 0.0;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _FileCardCircularProgress oldWidget) {
    _lastProgress = oldWidget.progress;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: _kAnimationDuration,
      tween: Tween<double>(begin: _lastProgress, end: widget.progress),
      builder: (context, tweenProgress, child) {
        return CircularProgressIndicator(
          value: tweenProgress > 0 ? tweenProgress : null,
          strokeWidth: _kIndicatorStrokeWidth,
          color: widget.color,
        );
      },
    );
  }
}

/// Renders the linear progress bar at the bottom of the card.
/// Only visible when the actual network upload is happening or completed.
class _FileCardProgressSection extends StatelessWidget {
  const _FileCardProgressSection({
    required this.radius,
    required this.status,
    required this.progress,
    required this.height,
    required this.uploadColor,
  });

  final BorderRadius radius;
  final FileUploadStatus status;
  final double progress;
  final double height;
  final Color uploadColor;

  @override
  Widget build(BuildContext context) {
    // Invece di SizedBox.shrink() che azzera l'altezza, riserviamo
    // lo spazio esatto usando SizedBox(height: height).
    // Questo previene il "salto" di layout della card.
    if (status == FileUploadStatus.transforming ||
        status == FileUploadStatus.waiting) {
      return SizedBox(height: height);
    }

    // Se preferisci che la barra sparisca anche quando l'upload
    // è terminato (done), decommenta le tre righe seguenti:
    // if (status == FileUploadStatus.done) {
    //   return SizedBox(height: height);
    // }

    return _FileCardProgress(
      key: const ValueKey('_file_card_progress'),
      progress: progress,
      radius: radius,
      bottomRadius: radius,
      height: height,
      color: uploadColor,
      backgroundColor: uploadColor.withValues(alpha: _kProgressBackgroundAlpha),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<FileUploadStatus>('status', status));
    properties.add(DoubleProperty('progress', progress));
    properties.add(DoubleProperty('height', height));
    properties.add(ColorProperty('uploadColor', uploadColor));
  }
}

/// A stateful widget that handles the smooth animation of the linear progress bar.
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('progress', progress));
    properties.add(DoubleProperty('height', height));
    properties.add(ColorProperty('color', color));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
  }
}

class _FileCardProgressState extends State<_FileCardProgress> {
  late double _lastProgress;

  @override
  void initState() {
    _lastProgress = 0.0;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _FileCardProgress oldWidget) {
    // Keep track of the previous progress value to animate from it smoothly.
    _lastProgress = oldWidget.progress;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _lastProgress = 1.0;
    super.dispose();
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
          // Constrain the progress bar to match the card's bottom borders.
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
          color.withValues(alpha: _kOverlayAlpha),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: color),
        ),
        // 1. Ripristiniamo un padding uniforme e bilanciato
        padding: const WidgetStatePropertyAll(EdgeInsets.all(8.0)),
        // 2. Fissiamo rigorosamente le dimensioni a 44x44 senza stringere il widget da fuori
        fixedSize: const WidgetStatePropertyAll(
          Size(_kActionSize, _kActionSize),
        ),
        // 3. Disabilitiamo l'ingrandimento invisibile a 48px del Material Design
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // 4. (Opzionale ma raccomandato) Fissiamo una forma pulita per evitare distorsioni
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Icon(iconData, size: _kIconSize),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IconDataProperty('iconData', iconData))
      ..add(ColorProperty('color', color))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }
}

/// The various lifecycle states of the file upload process.
enum FileUploadStatus {
  /// File is selected, waiting for user or system trigger to begin upload.
  waiting,

  /// File is currently being modified locally (e.g., compressed or resized) before upload.
  transforming,

  /// File is actively being transferred to the remote server.
  uploading,

  /// The upload process was interrupted or failed.
  failed,

  /// The upload process successfully completed.
  done;

  /// Indicates if the remove (delete) action should be visible.
  bool get _showRemove => this == FileUploadStatus.done;

  /// Indicates if the retry action should be visible.
  bool get _showRetry => this == FileUploadStatus.failed;

  /// Indicates if the initial upload action should be visible.
  bool get _showUpload => this == FileUploadStatus.waiting;

  /// Indicates if the card should be visually dimmed and actions disabled.
  bool get _disabled =>
      this == FileUploadStatus.uploading ||
      this == FileUploadStatus.transforming;
}
