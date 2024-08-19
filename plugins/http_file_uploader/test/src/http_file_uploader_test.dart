import 'dart:convert';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:http/http.dart';
import 'package:http_file_uploader/http_file_uploader.dart';
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
              headers: {
                'Authorization': 'Bearer <your_token_here>',
                'Content-Type': 'application/json; charset=utf-8',
              },
            ),
          );
        await robot.expectUpload();
        expect(requestCount, 1);
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
            headers: (_) => {
              'Authorization': 'Bearer <your_token_here>',
              'Content-Type': 'application/json; charset=utf-8',
            },
          );
        });

      await robot.expectRetry();
      expect(requestCount, 2);
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
      final presentationRequests = <Request>[];

      final robot = HttpRobot(
        mockClientFn(
          onStatus: (_) {
            statusCount++;
            return;
          },
          onChunk: (_) {
            chunkCount++;
            return;
          },
          onPresentation: (request) {
            presentationRequests.add(request);
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
            presentBody: jsonEncode({'file_name': 'name'}),
            chunkPath: (presentation, _) => 'chunks/${presentation.id}',
            statusPath: (presentation) => 'status/${presentation.id}',
            statusParser: (response) =>
                const FileUploadStatusResponse(nextChunkOffset: 1),
            chunkSize: fileSize ~/ 2,
            presentHeaders: {
              'Authorization': 'Bearer <your_token_here>',
              'Content-Type': 'application/json; charset=utf-8',
            },
            chunkHeaders: (_, __) => {
              'Authorization': 'Bearer <your_token_here>',
              'Content-Type': 'application/json; charset=utf-8',
            },
          );
        });

      await robot.expectUpload();

      // presentation
      expect(
        presentationRequests.first.body,
        jsonEncode({'file_name': 'name'}),
      );
      expect(presentationRequests.first.headers, {
        'Authorization': 'Bearer <your_token_here>',
        'Content-Type': 'application/json; charset=utf-8',
      });

      // counts
      expect(presentationCount, 1);
      expect(chunkCount, 2);
      expect(statusCount, 0);
      expect(totalCount(), 3);
    });

    test('should retry restorable chunked file', () async {
      final statusRequests = <Request>[];
      const fileSize = 1024 * 1024;

      final robot = HttpRobot(
        mockClientFn(
          onStatus: (request) {
            statusRequests.add(request);
            statusCount++;
            return;
          },
          onChunk: (_) {
            chunkCount++;
            return;
          },
          onPresentation: (_) {
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
            presentBody: jsonEncode({'file_name': 'name'}),
            chunkPath: (presentation, _) => 'chunks/${presentation.id}',
            statusPath: (presentation) => 'status/${presentation.id}',
            statusParser: (response) =>
                const FileUploadStatusResponse(nextChunkOffset: 1),
            chunkSize: fileSize ~/ 2,
            presentHeaders: {
              'Authorization': 'Bearer <your_token_here>',
              'Content-Type': 'application/json; charset=utf-8',
            },
            chunkHeaders: (_, __) => {
              'Authorization': 'Bearer <your_token_here>',
              'Content-Type': 'application/json; charset=utf-8',
            },
          );
        });

      await robot.expectRetry();

      // counts
      expect(presentationCount, 1);
      expect(chunkCount, 1);
      expect(statusCount, 1);
      expect(totalCount(), 3);
    });
  });
}
