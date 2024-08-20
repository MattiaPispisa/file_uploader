import 'dart:async';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'file_uploader_robot.dart';

class MockFileUploadController extends Mock implements FileUploadController {}

class MockFileUploadHandler extends Mock implements FileUploadHandler {}

void main() {
  group(
    'FileUploader',
    () {
      testWidgets(
        'should build correctly',
        (tester) async {
          final robot = FileUploaderRobot(tester: tester);
          await robot.pumpFileUploader(builder: (_, __) => const SizedBox());
        },
      );

      testWidgets(
        'should be waiting adding files',
        (tester) async {
          final handler = MockFileUploadHandler();
          final file = utils.createFile();
          final robot = FileUploaderRobot(tester: tester);
          await robot.pumpFileUploader(
            builder: (_, __) => const SizedBox(),
            onFileAdded: (file) async => handler,
            onPressedAddFiles: () async => [file],
          );
          robot
            ..expectAddingFilesWidget()
            ..expectNoErrorOnFilesWidget()
            ..expectNoProcessingFilesWidget();
        },
      );

      testWidgets(
        'should tap add files',
        (tester) async {
          final handler = MockFileUploadHandler();
          final file = utils.createFile();
          final completer = Completer<bool>();

          final robot = FileUploaderRobot(tester: tester);
          await robot.pumpFileUploader(
            builder: (_, __) => const SizedBox(),
            onFileAdded: (file) async => handler,
            onPressedAddFiles: () async {
              await completer.future;
              return [file];
            },
          );

          await robot.tapAddFiles();
          await robot.pump();
          robot
            ..expectProcessingFilesWidget()
            ..expectNoAddingFilesWidget()
            ..expectNoErrorOnFilesWidget();

          completer.complete(true);
          await robot.pump();
          robot
            ..expectNoProcessingFilesWidget()
            ..expectAddingFilesWidget()
            ..expectNoErrorOnFilesWidget();
        },
      );

      testWidgets(
        'should go on error',
            (tester) async {
          final handler = MockFileUploadHandler();
          final completer = Completer<bool>();

          final robot = FileUploaderRobot(tester: tester);
          await robot.pumpFileUploader(
            builder: (_, __) => const SizedBox(),
            onFileAdded: (file) async => handler,
            onPressedAddFiles: () async {
              await completer.future;
              throw Error();
            },
          );

          await robot.tapAddFiles();
          await robot.pump();
          robot
            ..expectProcessingFilesWidget()
            ..expectNoAddingFilesWidget()
            ..expectNoErrorOnFilesWidget();

          completer.complete(true);
          await robot.pump();
          robot
            ..expectNoProcessingFilesWidget()
            ..expectNoAddingFilesWidget()
            ..expectErrorOnFilesWidget();
        },
      );
    },
  );
}
