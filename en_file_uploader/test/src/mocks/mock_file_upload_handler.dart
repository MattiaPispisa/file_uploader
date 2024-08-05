import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:mocktail/mocktail.dart';

class MockFileUploadPresentationResponse extends Mock
    implements FileUploadPresentationResponse {}

class MockFileChunk extends Mock implements FileChunk {}

class MockFileUploadHandler extends Mock implements FileUploadHandler {}

class MockFileUploadHandlerBuilder {
  MockFileUploadHandlerBuilder(this.file);

  final XFile file;

  Future<void> Function()? uploadFn;

  FileUploadHandler build() {
    final handler = MockFileUploadHandler();

    registerFallbackValue(MockFileUploadPresentationResponse());
    registerFallbackValue(MockFileChunk());

    when(
      () => handler.upload(
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async {
      return uploadFn?.call() ?? Future.value();
    });

    when(() => handler.file).thenReturn(file);

    return handler;
  }
}
