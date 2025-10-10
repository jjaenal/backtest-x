import 'package:flutter/foundation.dart';

class PerfMonitor {
  static final Map<String, Stopwatch> _watches = {};

  static void start(String tag) {
    final sw = Stopwatch()..start();
    _watches[tag] = sw;
  }

  static void end(String tag, {String? context}) {
    final sw = _watches[tag];
    if (sw == null) return;
    sw.stop();
    final ms = sw.elapsedMilliseconds;
    _watches.remove(tag);
    debugPrint('[Perf] $tag${context != null ? ' ($context)' : ''}: ${ms}ms');
  }
}
