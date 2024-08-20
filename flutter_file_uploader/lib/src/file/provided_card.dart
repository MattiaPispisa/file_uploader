import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

/// Apply [FileUploadControllerProvider] and [FileUploadControllerConsumer] to
/// [FileCard].
///
/// Use [FileCard] to build an agnostic file upload widget.
///
/// Use [FileUploadControllerProvider] and [FileUploadControllerConsumer]
/// to control the file upload
///
/// Business logic is controlled out of the box,
/// remaining parameters are just for style.
class ProvidedFileCard extends StatelessWidget {
  /// constructor to create a [FileCard] with
  /// the business logic already built in
  const ProvidedFileCard({
    required this.ref,
    required this.content,
    this.borderRadius,
    this.padding = const EdgeInsets.all(8),
    this.elevation,
    this.progressHeight = 10,
    this.uploadIcon = Icons.upload,
    this.uploadColor,
    this.retryColor,
    this.retryIcon = Icons.rotate_left_rounded,
    this.removeIcon = Icons.delete,
    this.removeColor,
    this.startUploadOnInit = true,
    super.key,
  });

  /// reference to [FileUploader]
  final FileUploaderRef ref;

  /// start upload on init
  final bool startUploadOnInit;

  /// [FileCard] borderRadius
  final BorderRadius? borderRadius;

  /// [FileCard] padding
  ///
  /// padding of [FileCard.content]
  final EdgeInsetsGeometry padding;

  /// [FileCard] elevation
  final double? elevation;

  /// [FileCard] progressHeight
  final double progressHeight;

  /// [FileCard] content
  final Widget content;

  /// [FileCard] uploadIcon
  final IconData uploadIcon;

  /// [FileCard] uploadColor
  final Color? uploadColor;

  /// [FileCard] retryIcon
  final IconData retryIcon;

  /// [FileCard] retryColor
  final Color? retryColor;

  /// [FileCard] removeIcon
  final IconData removeIcon;

  /// [FileCard] removeColor
  final Color? removeColor;

  @override
  Widget build(BuildContext context) {
    return FileUploadControllerProvider(
      ref: ref,
      startOnInit: startUploadOnInit,
      child: FileUploadControllerConsumer(
        builder: (context, model, _) {
          return FileCard(
            content: content,
            status: model.status,
            progress: model.progress,
            borderRadius: borderRadius,
            elevation: elevation,
            onRemove: model.removeCallback(),
            onRetry: model.retryCallback(),
            onUpload: model.uploadCallback(),
            padding: padding,
            progressHeight: progressHeight,
            removeColor: removeColor,
            removeIcon: removeIcon,
            retryColor: retryColor,
            retryIcon: retryIcon,
            uploadColor: uploadColor,
            uploadIcon: uploadIcon,
          );
        },
      ),
    );
  }
}
