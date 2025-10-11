import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';

class QuickStartTemplatesSheetModel extends BaseViewModel {
  String? selectedKey;

  void select(String key) {
    selectedKey = key;
    notifyListeners();
  }

  void openStrategyBuilder() {
    locator<NavigationService>().navigateToStrategyBuilderView();
  }
}
