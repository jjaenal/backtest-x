import 'package:stacked/stacked.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/deep_link_service.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/services/storage_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  // Branding: static version label for footer
  String get appVersion => 'v0.1.0';

  // Startup progress steps for a more informative splash experience
  final List<String> _startupSteps = const [
    'Initialize services',
    'Load cache',
    'Prepare UI',
  ];
  List<String> get startupSteps => _startupSteps;

  int _completedSteps = 0;
  int get completedSteps => _completedSteps;

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    // Simulate step-by-step startup progress
    _completedSteps = 0;
    notifyListeners();

    // Step 1: Initialize services (DB, caches)
    for (var i = 0; i < _startupSteps.length; i++) {
      // Base work delay per step
      await Future.delayed(const Duration(milliseconds: 700));
      _completedSteps = i + 1;
      notifyListeners();
      // Micro-delay to let UI transition breathe
      await Future.delayed(const Duration(milliseconds: 220));

      // Hook actual work per step
      if (i == 0) {
        // Initialize storage to create DB tables early
        await locator<StorageService>().database;
      } else if (i == 1) {
        // Warm up cache from disk only; no auto-seeding sample data
        locator<DataManager>().warmUpCacheInBackground(force: true);
      }
    }

    await Future.delayed(const Duration(milliseconds: 4000));

    // This is where you can make decisions on where your app should navigate when
    // you have custom startup logic
    final handledDeepLink =
        await locator<DeepLinkService>().maybeHandleInitialLink();
    if (!handledDeepLink) {
      _navigationService.replaceWithHomeView();
    }
  }
}
