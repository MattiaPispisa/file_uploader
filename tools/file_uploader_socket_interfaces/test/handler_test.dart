import 'package:en_file_uploader/src/entity/file_chunk.dart';
import 'package:en_file_uploader/src/entity/file_upload_presentation_response.dart';
import 'package:en_file_uploader/src/entity/file_upload_status_response.dart';
import 'package:en_file_uploader/src/entity/progress.dart';
import 'package:file_uploader_socket_interfaces/file_uploader_socket_interfaces.dart';
import 'package:file_uploader_socket_interfaces/src/default.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'defaults',
    () {
      test('chunk parser should returns normally', () {
        expect(
          () {
            kChunkParser(2);
          },
          returnsNormally,
        );
      });
    },
  );
  group(
    'socket handlers',
    () {
      test(
        'should constructor SocketFileHandler correctly',
        () {
          final file = utils.createFile();
          final handler = MockSocketFileHandler(
            file: file,
            path: '/upload',
          );

          // defaults
          expect(handler.fileKey, 'file');
          expect(handler.method, 'POST');
          expect(handler.fileParser, isNotNull);

          // constructor
          expect(handler.file, file);
          expect(handler.path, '/upload');
        },
      );

      test(
        'should constructor MockSocketChunkedFileHandler correctly',
        () {
          final file = utils.createFile();
          final handler = MockSocketChunkedFileHandler(
            file: file,
            path: '/upload',
            chunkSize: 100,
          );

          // defaults
          expect(handler.fileKey, 'file');
          expect(handler.method, 'POST');
          expect(handler.chunkParser, isNotNull);

          // constructor
          expect(handler.file, file);
          expect(handler.path, '/upload');
          expect(handler.chunkSize, 100);
        },
      );

      test(
        'should constructor MockSocketRestorableChunkedFileHandler correctly',
        () {
          const presentationResponse = FileUploadPresentationResponse(
            id: '3',
          );
          final file = utils.createFile();
          final handler = MockSocketRestorableChunkedFileHandler(
            presentPath: '/present',
            chunkPath: (_, __) => '/chunk',
            statusPath: (_) => '/status',
            presentParser: (_) => presentationResponse,
            statusParser: (_) =>
                const FileUploadStatusResponse(nextChunkOffset: 0),
            file: file,
          );

          // defaults
          expect(handler.fileKey, 'file');
          expect(handler.presentMethod, 'POST');
          expect(handler.chunkMethod, 'POST');
          expect(handler.chunkMethod, 'POST');
          expect(handler.chunkParser, isNotNull);

          // constructor
          expect(handler.file, file);
          expect(handler.presentPath, '/present');
          expect(
            handler.chunkPath(
              presentationResponse,
              FileChunk(file: file, start: 0, end: 100),
            ),
            '/chunk',
          );
          expect(handler.statusPath(presentationResponse), '/status');
        },
      );
    },
  );
}

class MockSocketFileHandler extends SocketFileHandler<int> {
  MockSocketFileHandler({
    required super.file,
    required super.path,
    super.body,
    super.fileKey,
    super.fileParser,
    super.headers,
    super.method,
  });

  @override
  Future<void> upload({ProgressCallback? onProgress}) {
    throw UnimplementedError();
  }
}

class MockSocketChunkedFileHandler extends SocketChunkedFileHandler<int> {
  MockSocketChunkedFileHandler({
    required super.file,
    required super.path,
    super.body,
    super.chunkParser,
    super.chunkSize,
    super.fileKey,
    super.headers,
    super.method,
  });

  @override
  Future<void> uploadChunk(FileChunk chunk, {ProgressCallback? onProgress}) {
    throw UnimplementedError();
  }
}

class MockSocketRestorableChunkedFileHandler
    extends SocketRestorableChunkedFileHandler<int> {
  MockSocketRestorableChunkedFileHandler({
    required super.file,
    required super.presentPath,
    required super.chunkPath,
    required super.statusPath,
    required super.presentParser,
    required super.statusParser,
    super.chunkBody,
    super.chunkHeaders,
    super.chunkMethod,
    super.chunkParser,
    super.chunkSize,
    super.fileKey,
    super.presentBody,
    super.presentHeaders,
    super.presentMethod,
    super.statusBody,
    super.statusHeaders,
    super.statusMethod,
  });

  @override
  Future<FileUploadPresentationResponse> present() {
    throw UnimplementedError();
  }

  @override
  Future<FileUploadStatusResponse> status(
    FileUploadPresentationResponse presentation,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> uploadChunk(
    FileUploadPresentationResponse presentation,
    FileChunk chunk, {
    ProgressCallback? onProgress,
  }) {
    throw UnimplementedError();
  }
}
