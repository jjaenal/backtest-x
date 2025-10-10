import 'package:stacked/stacked.dart';

class OnboardingSheetModel extends BaseViewModel {
  int _step = 0;
  int get step => _step;

  void next() {
    _step = (_step + 1).clamp(0, 3);
    notifyListeners();
  }

  void back() {
    _step = (_step - 1).clamp(0, 3);
    notifyListeners();
  }
}
