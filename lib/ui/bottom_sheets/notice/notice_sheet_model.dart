import 'package:stacked/stacked.dart';

class NoticeSheetModel extends BaseViewModel {
  String? _selectedValue;
  String? get selectedValue => _selectedValue;

  void setSelectedValue(String? value) {
    _selectedValue = value;
    notifyListeners();
  }
}
