import 'package:flutter/widgets.dart';
import 'package:flutter_file_uploader_example/settings/model.dart';
import 'package:provider/provider.dart';

extension ExampleSettingsHelper on BuildContext {
  ExampleSettings watchSettings() {
    return watch<ExampleSettings>();
  }
}
