import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_test/flutter_test.dart';

import 'file_card_robot.dart';

void main() {
  group(
    'FileCard',
    () {
      testWidgets('should show remove button', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(status: FileUploadStatus.done);

        robot
          ..expectRemoveButton()
          ..expectNoUploadButton()
          ..expectNoTransformingIndicator()
          ..expectNoRetryButton()
          ..expectDebugFillProperties(FileUploadStatus.done);
      });

      testWidgets('should show retry button', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(status: FileUploadStatus.failed);

        robot
          ..expectNoRemoveButton()
          ..expectNoUploadButton()
          ..expectRetryButton()
          ..expectNoTransformingIndicator()
          ..expectDebugFillProperties(FileUploadStatus.failed);
      });

      testWidgets('should show upload button', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(status: FileUploadStatus.waiting);

        robot
          ..expectNoRemoveButton()
          ..expectUploadButton()
          ..expectNoTransformingIndicator()
          ..expectNoRetryButton()
          ..expectDebugFillProperties(FileUploadStatus.waiting);
      });

      testWidgets('should not show buttons', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(status: FileUploadStatus.uploading);

        robot
          ..expectNoRemoveButton()
          ..expectNoUploadButton()
          ..expectNoTransformingIndicator()
          ..expectNoRetryButton()
          ..expectDebugFillProperties(FileUploadStatus.uploading);
      });

      testWidgets('should show transforming indicator', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(status: FileUploadStatus.transforming);

        robot
          ..expectNoRemoveButton()
          ..expectNoUploadButton()
          ..expectNoRetryButton()
          ..expectTransformingIndicator()
          ..expectDebugFillProperties(FileUploadStatus.transforming);
      });

      testWidgets('should set transforming progress indicator', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(
          status: FileUploadStatus.transforming,
          transformationProgress: 0.5,
        );
        await robot.settle();
        robot.expectTransformingProgress(0.5);
      });

      testWidgets('should update transforming progress indicator', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(
          status: FileUploadStatus.transforming,
          transformationProgress: 0.5,
        );
        await robot.pumpFileCard(
          status: FileUploadStatus.transforming,
          transformationProgress: 1.0,
        );
        await robot.settle();
        robot.expectTransformingProgress(1.0);
      });

      testWidgets('should set upload progress indicator', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(status: FileUploadStatus.uploading);
        robot.expectProgress(0);
      });

      testWidgets('should set upload progress indicator', (tester) async {
        final robot = FileCardRobot(tester: tester);

        await robot.pumpFileCard(
          status: FileUploadStatus.uploading,
          progress: 1,
        );
        await robot.settle();
        robot.expectProgress(1);
      });

      testWidgets('should update upload progress indicator', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(status: FileUploadStatus.uploading);

        await robot.expectProgressUpdate(from: 0, to: 0.5);
      });

      testWidgets(
        'should delay UI update on transition from transforming to uploading',
        (tester) async {
          final robot = FileCardRobot(tester: tester);
          await robot.pumpFileCard(status: FileUploadStatus.transforming);

          await robot.pumpFileCard(status: FileUploadStatus.uploading);

          // Before timer is completed, it should still show transforming indicator
          robot.expectTransformingIndicator();

          // Wait for the animation delay to finish
          await tester.pumpAndSettle(const Duration(milliseconds: 350));

          robot.expectNoTransformingIndicator();
        },
      );

      testWidgets(
        'should cancel timer if unmounted during transforming -> uploading transition',
        (tester) async {
          final robot = FileCardRobot(tester: tester);
          await robot.pumpFileCard(status: FileUploadStatus.transforming);

          await robot.pumpFileCard(status: FileUploadStatus.uploading);

          // Unmount by pumping a different widget
          await tester.pumpWidget(const SizedBox());

          // Wait for the animation delay to finish
          await tester.pump(const Duration(milliseconds: 350));
        },
      );
    },
  );
}
