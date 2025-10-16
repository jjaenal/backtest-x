import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  bool get isLoggedIn => _client.auth.currentSession != null;

  Stream<AuthState> get authState => _client.auth.onAuthStateChange;

  Future<void> signInWithGoogle({String? redirectTo}) async {
    final rt = redirectTo ?? (kIsWeb ? Uri.base.origin : null);
    await _client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: rt);
  }

  Future<AuthResponse> signUpWithEmail(
      {required String email, required String password}) async {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInWithEmail(
      {required String email, required String password}) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> sendPasswordResetEmail(
      {required String email, String? redirectTo}) async {
    await _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  Future<UserResponse> updatePassword({required String newPassword}) async {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ===== Post-login redirect support =====
  // Simple holder for a pending redirect after successful authentication
  PostLoginRedirect? _postLoginRedirect;

  void setPostLoginRedirect(String route, {dynamic arguments}) {
    _postLoginRedirect = PostLoginRedirect(route, arguments: arguments);
  }

  PostLoginRedirect? takePostLoginRedirect() {
    final r = _postLoginRedirect;
    _postLoginRedirect = null;
    return r;
  }

  PostLoginRedirect? getPostLoginRedirect() => _postLoginRedirect;
}

class PostLoginRedirect {
  final String route;
  final dynamic arguments;
  PostLoginRedirect(this.route, {this.arguments});
}
