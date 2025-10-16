import 'package:stacked/stacked.dart';

class ChangePasswordDialogModel extends BaseViewModel {
  String newPassword = '';
  String confirmPassword = '';
  String? errorMessage;
  String? infoMessage;
  bool obscureNew = true;
  bool obscureConfirm = true;

  double strengthValue = 0.0; // 0.0 - 1.0
  String strengthLabel = '';

  void updateNewPassword(String value) {
    newPassword = value;
    _computeStrength(value);
    notifyListeners();
  }

  void _computeStrength(String pwd) {
    if (pwd.isEmpty) {
      strengthValue = 0.0;
      strengthLabel = '';
      return;
    }

    int score = 0;
    if (pwd.length >= 6) score += 1;
    if (pwd.length >= 8) score += 1;
    if (pwd.length >= 12) score += 1;

    final hasLower = RegExp(r'[a-z]').hasMatch(pwd);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pwd);
    final hasDigit = RegExp(r'\d').hasMatch(pwd);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(pwd);

    score += [hasLower, hasUpper, hasDigit, hasSpecial].where((b) => b).length;

    // Map score (0-7) to 0.0-1.0
    strengthValue = (score / 7.0).clamp(0.0, 1.0);

    if (strengthValue < 0.35) {
      strengthLabel = 'Lemah';
    } else if (strengthValue < 0.7) {
      strengthLabel = 'Sedang';
    } else {
      strengthLabel = 'Kuat';
    }
  }
}
