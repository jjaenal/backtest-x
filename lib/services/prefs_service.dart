// Conditional export to provide a Web-safe implementation.
// On Web, we export prefs_service_web_impl.dart; otherwise, prefs_service_io_impl.dart.
export 'prefs_service_io_impl.dart'
    if (dart.library.html) 'prefs_service_web_impl.dart';
