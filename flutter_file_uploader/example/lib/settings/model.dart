import 'dart:math';

import 'package:flutter/widgets.dart';

int _minLimit = 1;

class ExampleSettings extends ChangeNotifier {
  ExampleSettings({
    bool? hideOnLimit,
    int? limit,
    Color? color,
  })  : _limit = limit,
        _hideOnLimit = hideOnLimit,
        _color = color;

  int? _limit;
  int? get limit => _limit;
  set limit(int? limit) {
    _limit = limit;
    notifyListeners();
  }

  void incrementLimit() {
    limit = (_limit ?? _minLimit) + 1;
  }

  void decrementLimit() {
    limit = max((_limit ?? _minLimit) - 1, _minLimit);
  }

  bool? _hideOnLimit;
  bool? get hideOnLimit => _hideOnLimit;
  set hideOnLimit(bool? hideOnLimit) {
    _hideOnLimit = hideOnLimit;
    notifyListeners();
  }

  void toggleHideOnLimit() {
    hideOnLimit = !(_hideOnLimit ?? false);
  }

  Color? _color;
  Color? get color => _color;
  set color(Color? color) {
    _color = color;
    notifyListeners();
  }

  void randomColor() {
    color = _getRandomColor();
  }

  Color _getRandomColor() {
    final Random random = Random();

    int red = random.nextInt(256);
    int green = random.nextInt(256);
    int blue = random.nextInt(256);

    return Color.fromARGB(255, red, green, blue);
  }
}
