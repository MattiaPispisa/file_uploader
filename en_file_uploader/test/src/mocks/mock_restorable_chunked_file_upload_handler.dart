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

  RestorableChunkedFileUploadHandler build() {
    final handler = MockRestorableChunkedFileUploadHandler();

    registerFallbackValue(MockFileUploadPresentationResponse());
    registerFallbackValue(MockFileChunk());

    when(handler.present).thenAnswer((_) async {
      return presentationFn?.call() ??
          Future.value(const FileUploadPresentationResponse(id: 'id'));
    });

    when(() => handler.status(any())).thenAnswer((_) async {
      return statusFn?.call() ??
          Future.value(const FileUploadStatusResponse(nextChunkOffset: 1));
    });

    when(
      () => handler.uploadChunk(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((invocation) async {
      final chunk = invocation.positionalArguments[1] as FileChunk;
      final onProgressCallback =
          invocation.namedArguments[const Symbol('onProgress')] as void
              Function(int, int)?;

      onProgressCallback?.call(
        chunk.end - chunk.start,
        0,
      );

      return chunkFn?.call() ?? Future.value();
    });

    when(() => handler.file).thenReturn(file);

    when(() => handler.chunkSize).thenReturn(chunkSize);

    return handler;
  }
}
