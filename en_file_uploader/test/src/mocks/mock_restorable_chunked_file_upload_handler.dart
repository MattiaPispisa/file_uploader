import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:mocktail/mocktail.dart';

class MockFileUploadPresentationResponse extends Mock
    implements FileUploadPresentationResponse {}

class MockFileChunk extends Mock implements FileChunk {}

class MockRestorableChunkedFileUploadHandler extends Mock
    implements RestorableChunkedFileUploadHandler {}

class MockRestorableChunkedFileUploadHandlerBuilder {
  MockRestorableChunkedFileUploadHandlerBuilder(this.file);

  final XFile file;

  Future<FileUploadPresentationResponse> Function()? presentationFn;
  Future<FileUploadStatusResponse> Function()? statusFn;
  Future<void> Function()? chunkFn;

  int? chunkSize;

  /// If true, simulates behavior with multiple progress calls per chunk
  bool simulateMultipleProgressCalls = false;

  RestorableChunkedFileUploadHandler build() {
    final handler = MockRestorableChunkedFileUploadHandler();

    registerFallbackValue(MockFileUploadPresentationResponse());
    registerFallbackValue(MockFileChunk());

    when(handler.present).thenAnswer((_) async {
      return presentationFn?.call() ??
          Future.value(const FileUploadPresentationResponse(id: 'id'));
    });

    when(() => handler.status(any<FileUploadPresentationResponse>()))
        .thenAnswer((_) async {
      return statusFn?.call() ??
          Future.value(const FileUploadStatusResponse(nextChunkOffset: 1));
    });

    when(
      () => handler.uploadChunk(
        any<FileUploadPresentationResponse>(),
        any<FileChunk>(),
        onProgress: any<ProgressCallback>(named: 'onProgress'),
      ),
    ).thenAnswer((invocation) async {
      final chunk = invocation.positionalArguments[1] as FileChunk;
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
