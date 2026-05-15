import 'dart:async';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'file_upload_controller_model_robot.dart';

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
            ..expectTransformationProgress(0)
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

      test(
        'should transition through transforming → uploading → done',
        () async {
          final transformationDone = Completer<void>();

          final ref = MockFileUploaderRef();
          when(() => ref.hasTransformers).thenReturn(true);
          when(() => ref.transformersApplied).thenReturn(false);
          when(() => ref.onRemoved).thenReturn(() {});

          final uploadResult = FileUploadResult(
            id: 'id',
            file: createFile(),
          );

          when(
            () => ref.upload(
              onProgress: any(named: 'onProgress'),
              onTransformationProgress: any(named: 'onTransformationProgress'),
            ),
          ).thenAnswer((inv) async {
            final onTp =
                inv.namedArguments[const Symbol('onTransformationProgress')]
                    as void Function(double)?;
            onTp?.call(0.5);
            onTp?.call(1.0);
            transformationDone.complete();
            final onProg = inv.namedArguments[const Symbol('onProgress')]
                as void Function(int, int)?;
            onProg?.call(100, 100);
            return uploadResult;
          });

          final statuses = <FileUploadStatus>[];
          late FileUploadControllerModel model;
          // ignore: prefer_final_locals
          model = FileUploadControllerModel(ref: ref, startOnInit: false)
            ..addListener(() => statuses.add(model.status));

          model.upload();
          expect(model.status, FileUploadStatus.transforming);

          await transformationDone.future;
          await Future<void>.delayed(const Duration(milliseconds: 1));

          expect(statuses, contains(FileUploadStatus.transforming));
          expect(statuses, contains(FileUploadStatus.uploading));
          expect(statuses.last, FileUploadStatus.done);

          model.dispose();
        },
      );
    },
  );
}
