import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';

import 'provider.dart';

class ProvidedFileCard extends StatelessWidget {
  const ProvidedFileCard({
    super.key,
    required this.controller,
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
    this.onRemove,
  });

  final FileUploadController controller;

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
  final VoidCallback? onRemove;
  final Color? removeColor;

  @override
  Widget build(BuildContext context) {
    return FileUploadControllerProvider(
      controller: controller,
      child: FileUploadControllerConsumer(
        builder: (context, model, _) {
          return FileCard(
            content: content,
            semantic: model.semantic,
            progress: model.progress,
            borderRadius: borderRadius,
            elevation: elevation,
            onRemove: onRemove,
            onRetry: model.retryCallback,
            onUpload: model.uploadCallback,
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
