import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/ui/views/strategy_builder/strategy_builder_viewmodel.dart';

class TemplatePickerSheetModel extends BaseViewModel {
  final _bottomSheetService = locator<BottomSheetService>();

  StrategyBuilderViewModel? _strategyBuilderViewModel;

  void initialize(StrategyBuilderViewModel viewModel) {
    _strategyBuilderViewModel = viewModel;
  }

  String get selectedTemplateQuery =>
      _strategyBuilderViewModel?.selectedTemplateQuery ?? '';
  Set<String> get selectedTemplateCategories =>
      _strategyBuilderViewModel?.selectedTemplateCategories.toSet() ?? {};
  List<String> get recentTemplateKeys =>
      _strategyBuilderViewModel?.recentTemplateKeys ?? [];

  void updateTemplateQuery(String query) {
    _strategyBuilderViewModel?.selectedTemplateQuery = query;
    notifyListeners();
  }

  void updateTemplateCategories(Set<String> categories) {
    _strategyBuilderViewModel?.selectedTemplateCategories = categories.toList();
    notifyListeners();
  }

  void clearRecentTemplates() {
    _strategyBuilderViewModel?.clearRecentTemplates();
    notifyListeners();
  }

  void applyTemplate(String templateKey) {
    _strategyBuilderViewModel?.applyTemplate(templateKey);
    _bottomSheetService
        .completeSheet(SheetResponse(confirmed: true, data: templateKey));
  }

  void closeSheet() {
    _bottomSheetService.completeSheet(SheetResponse(confirmed: false));
  }
}
