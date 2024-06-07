import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';

class FileUploader extends StatelessWidget {
  const FileUploader({
    super.key,
    this.height = 100,
    this.width = double.maxFinite,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: DashedBorder.all(
          dashLength: 10,
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }
}
