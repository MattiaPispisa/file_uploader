import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'file_upload_controller_model_robot.dart';

class MockFileUploaderRef extends Mock implements FileUploaderRef {}

class MockCallbackFunction extends Mock {
  void call();
}

void main() {
  group(
    'FileUploadControllerModel',
    () {
      late FileUploadControllerModelRobot robot;

      tearDown(() {
        robot.dispose();
      });

      test(
        'should not start upload on init',
        () {
          robot = FileUploadControllerModelRobot()
            ..expectStatus(FileUploadStatus.waiting)
            ..expectProgress(0)
            ..expectUploadCalled(0)
            ..expectRetryCalled(0);
        },
      );

      test(
        'should start upload on init',
        () async {
          robot = FileUploadControllerModelRobot(startOnInit: true);

          await Future<void>.delayed(const Duration(milliseconds: 1));

          robot
            ..expectUploadCalled()
            ..expectRetryCalled(0)
            ..expectStatus(FileUploadStatus.done);
        },
      );

      test(
        'should upload',
        () async {
          robot = FileUploadControllerModelRobot()
            ..expectCanUpload()
            ..model.upload()
            ..expectStatus(FileUploadStatus.uploading);

          await Future<void>.delayed(const Duration(milliseconds: 1));

          robot
            ..expectUploadCompleted()
            ..expectChangeNotifierCalled(3)
            ..expectUploadCalled()
            ..expectRetryCalled(0);
        },
      );

      test(
        'should not upload a second time',
        () async {
          // upload
          robot = FileUploadControllerModelRobot()
            ..expectCanUpload()
            ..model.upload()
            ..expectStatus(FileUploadStatus.uploading);
          await Future<void>.delayed(const Duration(milliseconds: 1));

          robot
            ..expectChangeNotifierCalled(3)
            ..expectUploadCompleted();

          // second upload
          robot.model.upload();
          robot
            ..expectCanNotUpload()
            ..expectChangeNotifierCalled(0)
            ..expectUploadCompleted();
        },
      );

      test(
        'should retry',
        () async {
          robot = FileUploadControllerModelRobot()
            ..expectCanRetry()
            ..model.retry();

          await Future<void>.delayed(const Duration(milliseconds: 1));

          robot
            ..expectUploadCompleted()
            ..expectChangeNotifierCalled(3)
            ..expectUploadCalled(0)
            ..expectRetryCalled();
        },
      );

      test(
        'should fail',
        () async {
          robot = FileUploadControllerModelRobot(throwErrorOnUpload: true)
            ..model.upload();

          await Future<void>.delayed(const Duration(milliseconds: 1));

          robot
            ..expectStatus(FileUploadStatus.failed)
            ..expectChangeNotifierCalled(2);
        },
      );

      test(
        'should remove file',
        () async {
          robot = FileUploadControllerModelRobot()
            ..expectCanNotRemove()
            ..model.upload();

          await Future<void>.delayed(const Duration(milliseconds: 1));

          robot
            ..expectCanRemove()
            ..model.removeCallback()?.call()
            ..expectRemoveCalled();
        },
      );
    },
  );
}
