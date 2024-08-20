import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_test/flutter_test.dart';

class FileUploaderRobot {
  const FileUploaderRobot({
    required WidgetTester tester,
  }) : _tester = tester;

  final WidgetTester _tester;

  Future<void> pumpFileUploader({
    required FileUploaderBuilderCallback builder,
    Future<List<XFile>> Function()? onPressedAddFiles,
    Future<IFileUploadHandler> Function(XFile)? onFileAdded,
  }) {
    return _tester.pumpWidget(
      Material(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: FileUploader(
            builder: builder,
            onPressedAddFiles: onPressedAddFiles,
            onFileAdded: onFileAdded,
          ),
        ),
      ),
    );
  }

  Future<void> tapAddFiles() {
    return _tester.tap(find.byType(InkWell));
  }

  Future<void> pumpAndSettle() {
    return _tester.pumpAndSettle();
  }

  Future<void> pump() {
    return _tester.pump();
  }

  void expectProcessingFilesWidget() {
    expect(
      find.byKey(const ValueKey('file_uploader_loading')),
      findsOneWidget,
    );
  }

  void expectNoProcessingFilesWidget() {
    expect(
      find.byKey(const ValueKey('file_uploader_loading')),
      findsNothing,
    );
  }

  void expectErrorOnFilesWidget() {
    expect(
      find.byKey(const ValueKey('file_uploader_error')),
      findsOneWidget,
    );
  }


  void expectNoErrorOnFilesWidget() {
    expect(
      find.byKey(const ValueKey('file_uploader_error')),
      findsNothing,
    );
  }

  void expectAddingFilesWidget() {
    expect(
      find.byKey(const ValueKey('file_uploader_placeholder')),
      findsOneWidget,
    );
  }

  void expectNoAddingFilesWidget() {
    expect(
      find.byKey(const ValueKey('file_uploader_placeholder')),
      findsNothing,
    );
  }
}