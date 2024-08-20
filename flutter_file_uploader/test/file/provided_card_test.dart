import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFileUploaderRef extends Mock implements FileUploaderRef {}

void main() {
  group(
    'ProvidedFileCard',
    () {
      // These is just a wrapper around the other widgets created so I just
      // check that there are no errors in constructions

      testWidgets(
        'build FileUploadControllerProvider correctly',
        (tester) async {
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: ProvidedFileCard(
                ref: MockFileUploaderRef(),
                startUploadOnInit: false,
                content: const SizedBox(),
              ),
            ),
          );
        },
      );
    },
  );
}
