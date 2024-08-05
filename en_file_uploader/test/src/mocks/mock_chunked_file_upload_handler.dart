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

  ChunkedFileUploadHandler build() {
    final handler = MockChunkedFileUploadHandler();

    registerFallbackValue(MockFileUploadPresentationResponse());
    registerFallbackValue(MockFileChunk());

    when(
      () => handler.uploadChunk(
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async {
      return chunkFn?.call() ?? Future.value();
    });

    when(() => handler.file).thenReturn(file);

    when(() => handler.chunkSize).thenReturn(chunkSize);

    return handler;
  }
}
