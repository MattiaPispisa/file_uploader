import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'mocks/mock_file_upload_handler.dart';
import 'robot.dart';

void main() {
  group(
    'file_uploader - file handler',
    () {
      late Robot r;
      late FileUploadHandler handler;

      tearDown(() {
        r.dispose();
      });

      test('should stop on upload, restart on retry', () async {
        var uploadIteration = 0;

        r = Robot()
          ..createFile()
          ..createController((file) {
            final builder = MockFileUploadHandlerBuilder(file)
              ..uploadFn = () {
                if (uploadIteration == 0) {
                  uploadIteration++;
                  throw Exception('something went wrong');
                }
                uploadIteration++;
                return Future.value();
              };

            return handler = builder.build();
          });

        await r.expectUploadError<Exception>();

        verify(
          () => handler.upload(
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);

        await r.expectRetry();

        // repeat upload
        verify(
          () => handler.upload(
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
      });
    },
  );
}
