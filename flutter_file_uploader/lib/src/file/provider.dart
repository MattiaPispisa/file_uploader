import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:provider/provider.dart';

/// {@template file_upload_controller_provider}
/// [ChangeNotifierProvider] with [FileUploadControllerModel]
///
/// ```dart
/// class MyCustomFileUploadWidget extends StatelessWidget {
///
///   Widget build(BuildContext context) {
///     return FileUploadControllerProvider(
///       ref: ref,
///       child: FileUploadControllerConsumer(
///         builder: (context, model, _) {
///           // UI Widget
///           return ...
///         ...
/// ```
/// {@endtemplate}
class FileUploadControllerProvider extends StatelessWidget {
  /// {@macro file_upload_controller_provider}
  ///
  /// [ChangeNotifierProvider] with [FileUploadControllerModel]
  const FileUploadControllerProvider({
    required this.ref,
    required this.child,
    this.startOnInit = true,
    super.key,
  });

  /// reference to [FileUploader]
  final FileUploaderRef ref;

  /// start upload on init
  final bool startOnInit;

  /// child
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FileUploadControllerModel(
        ref: ref,
        startOnInit: startOnInit,
      ),
      child: child,
    );
  }
}

/// {@template file_upload_controller_selector}
/// [Selector] with [FileUploadControllerModel]
/// {@endtemplate}
class FileUploadControllerSelector<T> extends StatelessWidget {
  /// {@macro file_upload_controller_selector}
  ///
  /// [Selector] with [FileUploadControllerModel]
  const FileUploadControllerSelector({
    required this.selector,
    required this.builder,
    super.key,
    this.child,
  });

  /// Callback that return only the information needed for `builder` to complete
  ///
  /// Only when [T] change the `builder` is called
  final T Function(
    BuildContext context,
    FileUploadControllerModel model,
  ) selector;

  /// Callback executed on every change of [T].
  ///
  /// The parameter `child` is the one passed into
  /// [FileUploadControllerSelector].
  final Widget Function(
    BuildContext context,
    T value,
    Widget? child,
  ) builder;

  /// Widget not effected from [Selector]
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Selector<FileUploadControllerModel, T>(
      builder: builder,
      selector: selector,
      child: child,
    );
  }
}

/// {@template file_upload_controller_consumer}
/// [Consumer] with [FileUploadControllerModel]
/// {@endtemplate}
class FileUploadControllerConsumer extends StatelessWidget {
  /// {@macro file_upload_controller_consumer}
  ///
  /// [Consumer] with [FileUploadControllerModel]
  const FileUploadControllerConsumer({
    required this.builder,
    super.key,
    this.child,
  });

  /// Callback executed on every change of [FileUploadControllerModel].
  ///
  /// The parameter `child` is the one passed into
  /// [FileUploadControllerConsumer].
  final Widget Function(
    BuildContext context,
    FileUploadControllerModel model,
    Widget? child,
  ) builder;

  /// Widget not effected from [Consumer]
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Consumer<FileUploadControllerModel>(
      builder: builder,
      child: child,
    );
  }
}
