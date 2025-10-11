import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/ui/common/ui_helpers.dart';

void main() {
  group('showErrorWithRetry', () {
    test('uses provided show function and triggers retry', () {
      int calls = 0;
      dynamic lastVariant;
      String? lastTitle;
      String? lastMessage;
      String? lastMainButtonTitle;
      VoidCallback? lastOnMainButtonTapped;

      var retried = false;

      showErrorWithRetry(
        title: 'Test Error',
        message: 'Something went wrong',
        onRetry: () {
          retried = true;
        },
        customShowFn: ({
          variant,
          title,
          message,
          mainButtonTitle,
          onMainButtonTapped,
          duration,
        }) {
          calls++;
          lastVariant = variant;
          lastTitle = title;
          lastMessage = message;
          lastMainButtonTitle = mainButtonTitle;
          lastOnMainButtonTapped = onMainButtonTapped;
        },
      );

      expect(calls, 1);
      expect(lastTitle, 'Test Error');
      expect(lastMessage, 'Something went wrong');
      expect(lastMainButtonTitle, 'Coba lagi');

      // Simulate tapping main button
      lastOnMainButtonTapped?.call();
      expect(retried, isTrue);
    });
  });
}
