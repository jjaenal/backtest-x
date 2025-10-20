import 'package:flutter/material.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/ui/views/strategy_builder/strategy_builder_constants.dart';

class VerificationBanner extends StatelessWidget {
  final bool isBusy;
  final bool isResendEnabled;
  final bool resendCooldownActive;
  final int cooldownRemainingSeconds;
  final VoidCallback onResend;
  final VoidCallback onDismiss;
  final String? message;
  final String? resendLabel;
  final String? dismissLabel;

  const VerificationBanner({
    super.key,
    required this.isBusy,
    required this.isResendEnabled,
    required this.resendCooldownActive,
    required this.cooldownRemainingSeconds,
    required this.onResend,
    required this.onDismiss,
    this.message,
    this.resendLabel,
    this.dismissLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final msg = message ??
        (t?.errorAuthEmailNotConfirmed ??
            'Email belum terverifikasi. Cek inbox untuk verifikasi.');
    final resendText =
        resendLabel ?? (t?.userEmailResend ?? 'Kirim Ulang Email Verifikasi');
    final dismissText = dismissLabel ?? (t?.errorDismiss ?? 'Tutup');

    return Card(
      color: Theme.of(context)
          .colorScheme
          .tertiaryContainer
          .withValues(alpha: 0.2),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(StrategyBuilderConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: StrategyBuilderConstants.smallSpacing),
                Expanded(
                  child: Text(
                    msg,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: StrategyBuilderConstants.smallSpacing),
            Wrap(
              spacing: StrategyBuilderConstants.smallSpacing,
              runSpacing: StrategyBuilderConstants.microSpacing,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: (!isBusy && isResendEnabled) ? onResend : null,
                  icon: const Icon(Icons.mark_email_unread),
                  label: Text(resendText),
                ),
                TextButton.icon(
                  onPressed: isBusy ? null : onDismiss,
                  icon: const Icon(Icons.close),
                  label: Text(dismissText),
                ),
                if (resendCooldownActive)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                          width: StrategyBuilderConstants.microSpacing),
                      Text(
                        'Tunggu ${cooldownRemainingSeconds}s sebelum kirim ulang.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
