import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'file_uploader_robot.dart';

void main() {
  group(
    'FileUploader',
    () {
      testWidgets(
        'should construct correctly',
        (tester) async {
          final robot = FileUploaderRobot(tester: tester);
          await robot.pumpFileUploader(builder: (_, __) => const SizedBox());
        },
      );
    },
  );
}
