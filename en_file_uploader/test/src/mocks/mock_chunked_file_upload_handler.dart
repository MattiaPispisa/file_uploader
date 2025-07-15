import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:mocktail/mocktail.dart';

class MockFileUploadPresentationResponse extends Mock
    implements FileUploadPresentationResponse {}

class MockFileChunk extends Mock implements FileChunk {}

class MockChunkedFileUploadHandler extends Mock
    implements ChunkedFileUploadHandler {}

class MockChunkedFileUploadHandlerBuilder {
  MockChunkedFileUploadHandlerBuilder(this.file);

  final XFile file;

  Future<void> Function()? chunkFn;

  int? chunkSize;

  /// If true, simulates Dio behavior with multiple progress calls per chunk
  bool simulateMultipleProgressCalls = false;

  ChunkedFileUploadHandler build() {
    final handler = MockChunkedFileUploadHandler();

    registerFallbackValue(MockFileUploadPresentationResponse());
    registerFallbackValue(MockFileChunk());

    when(
      () => handler.uploadChunk(
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((invocation) async {
      final chunk = invocation.positionalArguments[0] as FileChunk;
      final onProgressCallback =
          invocation.namedArguments[const Symbol('onProgress')] as void
              Function(int, int)?;

      final chunkTotalSize = chunk.end - chunk.start;

      if (simulateMultipleProgressCalls) {
        // Simulate multiple progress calls per chunk
        onProgressCallback?.call(chunkTotalSize ~/ 3, chunkTotalSize);
        onProgressCallback?.call((chunkTotalSize * 2) ~/ 3, chunkTotalSize);
        onProgressCallback?.call(chunkTotalSize, chunkTotalSize);
      } else {
        // Simulate single progress call per chunk
        onProgressCallback?.call(chunkTotalSize, chunkTotalSize);
      }

      return chunkFn?.call() ?? Future.value();
    });

    when(() => handler.file).thenReturn(file);

    when(() => handler.chunkSize).thenReturn(chunkSize);

    return handler;
  }
}
