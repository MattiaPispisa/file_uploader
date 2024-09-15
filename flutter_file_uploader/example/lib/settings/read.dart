import 'package:example/settings/model.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension ExampleSettingsHelper on BuildContext {
  ExampleSettings watchSettings() {
    return watch<ExampleSettings>();
  }
}
