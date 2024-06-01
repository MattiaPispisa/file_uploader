import 'package:file_uploader/file_uploader.dart';
import 'package:http/http.dart';
import 'package:http_file_uploader/http_file_uploader.dart';
import 'package:http_file_uploader/src/chunked_file_handler.dart';
import 'package:http_file_uploader/src/file_handler.dart';
import 'package:test/test.dart';

import 'robot.dart';

void main() {
  group('file handler', () {
    test(
      'should upload file',
      () async {
        var requestCount = 0;

        final robot = HttpRobot((request) {
          requestCount += 1;
          return Future.value(Response('', 200));
        })
          ..createFile()
          ..createController(
            (client, file) => HttpFileHandler(
              client: client,
              file: file,
              path: 'profile/image',
            ),
          );
        await robot.expectUpload();
        await robot.expectRetry();
        expect(requestCount, 2);
      },
    );
  });

  group('chunked file handler', () {
    test('should upload chunked file', () async {
      const fileSize = 1024 * 1024;
      var requestCount = 0;

      final robot = HttpRobot((request) {
        requestCount++;
        return Future.value(Response('', 200));
      })
        ..createFile(length: fileSize)
        ..createController((client, file) {
          return HttpChunkedFileHandler(
            client: client,
            file: file,
            path: 'profile/image',
            chunkSize: fileSize ~/ 2,
          );
        });

      await robot.expectUpload();
      expect(requestCount, 2);

      await robot.expectRetry();
      expect(requestCount, 4);
    });
  });

  group('restorable chunked file handler', () {
    var presentationCount = 0;
    var statusCount = 0;
    var chunkCount = 0;

    int totalCount() => presentationCount + statusCount + chunkCount;

    setUp(() {
      presentationCount = 0;
      statusCount = 0;
      chunkCount = 0;
    });

    test('should upload restorable chunked file', () async {
      const fileSize = 1024 * 1024;

      final robot = HttpRobot(
        mockClientFn(
          onStatus: () {
            statusCount++;
            return;
          },
          onChunk: () {
            chunkCount++;
            return;
          },
          onPresentation: () {
            presentationCount++;
            return;
          },
        ),
      )
        ..createFile(length: fileSize)
        ..createController((client, file) {
          return HttpRestorableChunkedFileHandler(
            client: client,
            file: file,
            presentPath: 'presentation',
            presentParser: (response) =>
                const FileUploadPresentationResponse(id: 'custom_id'),
            chunkPath: (presentation) => 'chunks/${presentation.id}',
            statusPath: (presentation) => 'status/${presentation.id}',
            statusParser: (response) =>
                const FileUploadStatusResponse(nextChunkOffset: 1),
            chunkSize: fileSize ~/ 2,
          );
        });

      await robot.expectUpload();
      expect(presentationCount, 1);
      expect(chunkCount, 2);
      expect(statusCount, 0);
      expect(totalCount(), 3);
    });
  });
}
