import 'package:stacked/stacked.dart';

abstract class BaseRefreshableViewModel extends BaseViewModel {
  Future<void> refresh();
}