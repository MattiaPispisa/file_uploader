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
  }) {
    return _tester.pumpWidget(
      Material(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: FileUploader(
            builder: builder,
          ),
        ),
      ),
    );
  }
}
