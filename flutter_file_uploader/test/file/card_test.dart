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
          ..expectNoRetryButton();
      });

      testWidgets('should show retry button', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(status: FileUploadStatus.failed);

        robot
          ..expectNoRemoveButton()
          ..expectNoUploadButton()
          ..expectRetryButton();
      });

      testWidgets('should show upload button', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(status: FileUploadStatus.waiting);

        robot
          ..expectNoRemoveButton()
          ..expectUploadButton()
          ..expectNoRetryButton();
      });

      testWidgets('should not show buttons', (tester) async {
        final robot = FileCardRobot(tester: tester);
        await robot.pumpFileCard(status: FileUploadStatus.uploading);

        robot
          ..expectNoRemoveButton()
          ..expectNoUploadButton()
          ..expectNoRetryButton();
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
    },
  );
}
