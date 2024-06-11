import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader/src/file_uploader/model.dart';

class ProvidedFileCard extends StatelessWidget {
  const ProvidedFileCard({
    super.key,
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
  });

  final FileUploaderRef ref;

  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;

  final double? elevation;

  final double progressHeight;

  final Widget content;

  final IconData uploadIcon;
  final Color? uploadColor;

  final IconData retryIcon;
  final Color? retryColor;

  final IconData removeIcon;
  final Color? removeColor;

  @override
  Widget build(BuildContext context) {
    return FileUploadControllerProvider(
      ref: ref,
      child: FileUploadControllerConsumer(
        builder: (context, model, _) {
          return FileCard(
            content: content,
            semantic: model.semantic,
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
