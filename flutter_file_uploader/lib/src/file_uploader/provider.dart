import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:provider/provider.dart';

/// [Selector] with [FileUploaderModel].
///
/// Can be used in [FileUploader] child widgets.
class FileUploaderSelector<T> extends StatelessWidget {
  /// [Selector] with [FileUploaderModel]
  const FileUploaderSelector({
    required this.selector,
    required this.builder,
    this.child,
    super.key,
  });

  /// Callback that return only the information needed for `builder` to complete
  ///
  /// Only when [T] change the `builder` is called
  final T Function(
    BuildContext context,
    FileUploaderModel model,
  ) selector;

  /// Callback executed on every change of [T].
  ///
  /// The parameter `child` is the one passed into
  /// [FileUploaderSelector].
  final Widget Function(
    BuildContext context,
    T value,
    Widget? child,
  ) builder;

  /// Widget not effected from [Selector]
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Selector<FileUploaderModel, T>(
      builder: builder,
      selector: selector,
      child: child,
    );
  }
}

/// [Consumer] with [FileUploaderModel].
///
/// Can be used in [FileUploader] child widgets.
class FileUploaderConsumer extends StatelessWidget {
  /// [Consumer] with [FileUploaderModel].
  const FileUploaderConsumer({
    required this.builder,
    this.child,
    super.key,
  });

  /// Callback executed on every change of [FileUploaderModel].
  ///
  /// The parameter `child` is the one passed into
  /// [FileUploaderConsumer].
  final Widget Function(
    BuildContext context,
    FileUploaderModel model,
    Widget? child,
  ) builder;

  /// Widget not effected from [Consumer]
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Consumer<FileUploaderModel>(
      builder: builder,
      child: child,
    );
  }
}
