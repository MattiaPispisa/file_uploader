import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFileUploaderRef extends Mock implements FileUploaderRef {}

class MockFileUploadController extends Mock implements FileUploadController {}

class MockCallbackFunction extends Mock {
  void call();
}

void main() {
  group(
    'FileUploadControllerModel',
    () {
      late FileUploaderRef ref;
      late FileUploadControllerModel model;

      setUp(() {
        ref = MockFileUploaderRef();
      });

      tearDown(() {
        model.dispose();
      });

      test(
        'should not start upload on init',
        () {
          model = FileUploadControllerModel(ref: ref, startOnInit: false);
          expect(model.status, FileUploadStatus.waiting);
          verifyNever(
            () => ref.upload(
              onProgress: any(named: 'onProgress'),
            ),
          );
          verifyNever(
            () => ref.retry(
              onProgress: any(named: 'onProgress'),
            ),
          );
        },
      );

      test(
        'should start upload on init',
        () {
          model = FileUploadControllerModel(ref: ref);
          verify(
            () => ref.upload(
              onProgress: any(named: 'onProgress'),
            ),
          ).called(1);
          verifyNever(
            () => ref.retry(
              onProgress: any(named: 'onProgress'),
            ),
          );
          expect(model.status, FileUploadStatus.done);
        },
      );

      test(
        'should upload',
        () async {
          final listener = MockCallbackFunction();
          model = FileUploadControllerModel(ref: ref, startOnInit: false)
            ..addListener(listener.call);

          expect(model.uploadCallback(), isNotNull);
          model.upload();

          await Future<void>.delayed(const Duration(milliseconds: 1));

          expect(model.status, FileUploadStatus.done);
          verify(
            () => ref.upload(
              onProgress: any(named: 'onProgress'),
            ),
          ).called(1);
          verifyNever(
            () => ref.retry(
              onProgress: any(named: 'onProgress'),
            ),
          );
        },
      );
    },
  );
}
