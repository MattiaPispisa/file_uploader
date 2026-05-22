import 'dart:math';

import 'package:flutter/widgets.dart';

int _minLimit = 1;

class ExampleSettings extends ChangeNotifier {
  ExampleSettings({
    bool? hideOnLimit,
    int? limit,
    Color? color,
    Locale? locale,
  })  : _limit = limit,
        _hideOnLimit = hideOnLimit,
        _color = color,
        _locale = locale;

  Locale? _locale;
  Locale? get locale => _locale;
  set locale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  int? _limit;
  int? get limit => _limit;
  set limit(int? limit) {
    _limit = limit;
    notifyListeners();
  }

  bool get canDecrementLimit => _limit != null && _limit! > _minLimit;
  bool get canIncrementLimit => true;

  void incrementLimit() {
    if (_limit == null) {
      limit = _minLimit;
      return;
    }
    limit = _limit! + 1;
  }

  void decrementLimit() {
    if (_limit == null) {
      return;
    }
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
