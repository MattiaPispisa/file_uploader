import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:mocktail/mocktail.dart';

class _MockFileUploadPresentationResponse extends Mock
    implements FileUploadPresentationResponse {}

class _MockFileChunk extends Mock implements FileChunk {}

class _MockFileUploadHandler extends Mock implements FileUploadHandler {}

class _MockXFile extends Mock implements XFile {}

class MockFileUploadHandlerBuilder {
  MockFileUploadHandlerBuilder(this.file);

  final XFile file;

  Future<void> Function()? uploadFn;

  FileUploadHandler build() {
    final handler = _MockFileUploadHandler();

    registerFallbackValue(_MockFileUploadPresentationResponse());
    registerFallbackValue(_MockFileChunk());
    registerFallbackValue(_MockXFile());

    when(
      () => handler.upload(
        any<XFile>(),
        onProgress: any<ProgressCallback>(named: 'onProgress'),
      ),
    ).thenAnswer((_) async {
      return uploadFn?.call() ?? Future.value();
    });

    when(() => handler.file).thenReturn(file);

    return handler;
  }
}
