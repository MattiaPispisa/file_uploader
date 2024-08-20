import 'package:flutter/cupertino.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockFileUploaderRef extends Mock implements FileUploaderRef {}

class MockFileCard extends StatelessWidget {
  const MockFileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<FileUploadControllerModel>().progress;
    return Text(progress.toString());
  }
}

void main() {
  group(
    'provider',
    () {
      // These are just wrappers around "provider" so I just check
      // that there are no errors in constructions
      // and retrieving "FileUploadControllerModel"

      testWidgets(
        'build FileUploadControllerProvider correctly',
        (tester) async {
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: FileUploadControllerProvider(
                ref: MockFileUploaderRef(),
                startOnInit: false,
                child: const MockFileCard(),
              ),
            ),
          );
        },
      );

      testWidgets(
        'build FileUploadControllerSelector correctly',
        (tester) async {
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: FileUploadControllerProvider(
                ref: MockFileUploaderRef(),
                startOnInit: false,
                child: FileUploadControllerSelector<double>(
                  selector: (_, model) => model.progress,
                  builder: (_, progress, __) => Text(progress.toString()),
                ),
              ),
            ),
          );
        },
      );

      testWidgets(
        'build FileUploadControllerConsumer correctly',
        (tester) async {
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: FileUploadControllerProvider(
                ref: MockFileUploaderRef(),
                startOnInit: false,
                child: FileUploadControllerConsumer(
                  builder: (_, model, __) => Text(model.progress.toString()),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
