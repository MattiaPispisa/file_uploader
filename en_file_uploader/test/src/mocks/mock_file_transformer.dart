import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:mocktail/mocktail.dart';

class _MockFileTransformer extends Mock implements FileTransformer {}

class _MockXFile extends Mock implements XFile {}

class MockFileTransformerBuilder {
  bool fail = false;

  Future<XFile> Function()? transformedFile;
  Future<void> Function()? cleanup;
  bool continueOnFailure = true;
  int? progressChunkCount;

  FileTransformer build() {
    final transformer = _MockFileTransformer();

    registerFallbackValue(_MockXFile());

    when(
      () => transformer.continueOnFailure,
    ).thenReturn(continueOnFailure);

    when(
      () => transformer.transform(
        any<XFile>(),
        onProgress: any<TransformationProgressCallback>(named: 'onProgress'),
      ),
    ).thenAnswer((invocation) {
      _simulateProgress(invocation);

      if (transformedFile != null) {
        return transformedFile!.call();
      }

      if (!fail) {
        return Future.value(utils.createFile(length: 512));
      }

      throw Exception('error transforming file');
    });

    when(() => transformer.cleanup(any<XFile>())).thenAnswer((_) {
      return cleanup?.call() ?? Future.value();
    });

    return transformer;
  }

  void _simulateProgress(Invocation invocation) {
    final onProgressCallback =
        invocation.namedArguments[const Symbol('onProgress')]
            as TransformationProgressCallback?;
    final count = progressChunkCount ?? 0;

    for (final index in List.generate(count, (index) => index)) {
      final fraction = count - index;
      onProgressCallback?.call(1 / fraction);
    }
  }
}
