import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/services/prefs_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

/// Service to build and handle deep links for Backtest-X
class DeepLinkService {
  final String? _baseUrlOverride;
  final bool? _useHashRoutingOverride;

  DeepLinkService({String? baseUrlOverride, bool? useHashRoutingOverride})
      : _baseUrlOverride = baseUrlOverride,
        _useHashRoutingOverride = useHashRoutingOverride;

  /// Build a deep link URL to open Backtest Result view for a given result id
  String buildBacktestResultLink({required String resultId}) {
    final base = _determineBaseUrl();
    final useHash = _determineUseHash();
    const routePath = Routes.backtestResultView; // '/backtest-result-view'
    final encodedId = Uri.encodeComponent(resultId);
    if (useHash) {
      return '$base/#$routePath?id=$encodedId';
    } else {
      return '$base$routePath?id=$encodedId';
    }
  }

  /// Build a deep link URL to open Strategy Builder for a given strategy id
  String buildStrategyLink({required String strategyId}) {
    final base = _determineBaseUrl();
    final useHash = _determineUseHash();
    const routePath = Routes.strategyBuilderView; // '/strategy-builder-view'
    final encodedId = Uri.encodeComponent(strategyId);
    final query = 'strategyId=$encodedId';
    if (useHash) {
      return '$base/#$routePath?$query';
    } else {
      return '$base$routePath?$query';
    }
  }

  /// Build a deep link URL to open Strategy Builder with optional template & data selection (onboarding)
  String buildOnboardingLink({String? templateKey, String? dataId}) {
    final base = _determineBaseUrl();
    final useHash = _determineUseHash();
    const routePath = Routes.strategyBuilderView; // '/strategy-builder-view'
    final params = <String, String>{};
    if (templateKey != null && templateKey.isNotEmpty) {
      params['templateKey'] = Uri.encodeComponent(templateKey);
    }
    if (dataId != null && dataId.isNotEmpty) {
      params['dataId'] = Uri.encodeComponent(dataId);
    }
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    if (useHash) {
      return query.isEmpty ? '$base/#$routePath' : '$base/#$routePath?$query';
    } else {
      return query.isEmpty ? '$base$routePath' : '$base$routePath?$query';
    }
  }

  /// Attempt to handle the initial URL (useful on web) and navigate accordingly
  Future<bool> maybeHandleInitialLink() async {
    if (!kIsWeb) return false;

    final location = html.window.location;
    final href = location.href;
    // Support both hash and path URL strategies
    final uri = Uri.tryParse(href);
    if (uri == null) return false;

    // Normalize: extract the path part after hash if present
    String path = uri.path;
    String query = uri.query;
    if (uri.fragment.isNotEmpty) {
      final fragUri = Uri.tryParse(uri.fragment);
      if (fragUri != null) {
        path = fragUri.path;
        query = fragUri.query;
      } else if (uri.fragment.startsWith('/')) {
        // Simple fallback
        final idx = uri.fragment.indexOf('?');
        path = idx == -1 ? uri.fragment : uri.fragment.substring(0, idx);
        query = idx == -1 ? '' : uri.fragment.substring(idx + 1);
      }
    }

    if (path == Routes.backtestResultView) {
      final q = Uri.splitQueryString(query);
      final id = q['id'];
      if (id != null && id.isNotEmpty) {
        return _openBacktestResult(id);
      }
    }
    if (path == Routes.strategyBuilderView) {
      final q = Uri.splitQueryString(query);
      final id = q['strategyId'] ?? q['id'];
      if (id != null && id.isNotEmpty) {
        return _openStrategy(id);
      }
      // Onboarding deep link: apply template & data selection
      final tpl = q['templateKey'];
      final dataId = q['dataId'];
      if ((tpl != null && tpl.isNotEmpty) || (dataId != null && dataId.isNotEmpty)) {
        try {
          final prefs = locator<PrefsService>();
          if (tpl != null && tpl.isNotEmpty) {
            prefs.setString('onboarding.pending_template_key', tpl);
          }
          if (dataId != null && dataId.isNotEmpty) {
            prefs.setString('onboarding.pending_data_id', dataId);
          }
        } catch (_) {}
        final nav = locator<NavigationService>();
        nav.navigateTo(Routes.strategyBuilderView);
        return true;
      }
    }
    return false;
  }

  Future<bool> _openBacktestResult(String id) async {
    final storage = locator<StorageService>();
    final nav = locator<NavigationService>();
    final result = await storage.getBacktestResult(id);
    if (result == null) return false;
    nav.navigateTo(Routes.backtestResultView,
        arguments: BacktestResultViewArguments(result: result));
    return true;
  }

  Future<bool> _openStrategy(String id) async {
    // Navigate directly; StrategyBuilderViewModel will load strategy by id
    final nav = locator<NavigationService>();
    nav.navigateTo(
      Routes.strategyBuilderView,
      arguments: StrategyBuilderViewArguments(strategyId: id),
    );
    return true;
  }

  String _determineBaseUrl() {
    if (_baseUrlOverride != null) return _baseUrlOverride!;
    if (kIsWeb) {
      final origin = html.window.location.origin ?? 'http://localhost';
      final basePath = html.window.location.pathname ?? '';
      // Trim trailing slash from basePath and origin
      String base = origin;
      // If hosted under a subpath, preserve it
      if (basePath.isNotEmpty &&
          basePath != '/' &&
          !basePath.endsWith('.html')) {
        // Remove trailing slash
        final trimmed = basePath.endsWith('/')
            ? basePath.substring(0, basePath.length - 1)
            : basePath;
        base = '$origin$trimmed';
      }
      return base;
    }
    // Fallback for non-web: provide a pseudo scheme-based link
    return 'backtestx://app';
  }

  bool _determineUseHash() {
    if (_useHashRoutingOverride != null) return _useHashRoutingOverride!;
    if (!kIsWeb) return false;
    final loc = html.window.location;
    // Heuristic: if there's already a hash pointing to a route, keep using it
    return (loc.hash.isNotEmpty);
  }
}
