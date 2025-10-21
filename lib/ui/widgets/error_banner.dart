import 'package:flutter/material.dart';
import 'package:backtestx/l10n/app_localizations.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondary;
  final String? secondaryLabel;
  final VoidCallback? onClose;
  final bool dense;

  const ErrorBanner({
    Key? key,
    required this.message,
    this.onRetry,
    this.onSecondary,
    this.secondaryLabel,
    this.onClose,
    this.dense = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      color: colorScheme.errorContainer,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 10 : 12,
          vertical: dense ? 8 : 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (onRetry != null)
                        TextButton.icon(
                          onPressed: onRetry,
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.onErrorContainer,
                          ),
                          icon: const Icon(Icons.refresh),
                          label: Text(
                              AppLocalizations.of(context)?.errorRetry ??
                                  'Retry'),
                        ),
                      if (onSecondary != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: TextButton.icon(
                            onPressed: onSecondary,
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.onErrorContainer,
                            ),
                            icon: const Icon(Icons.help_outline),
                            label: Text(
                              secondaryLabel ?? 'Learn more',
                            ),
                          ),
                        ),
                      const Spacer(),
                      IconButton(
                        tooltip: AppLocalizations.of(context)?.errorDismiss ??
                            'Dismiss',
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.onErrorContainer,
                        ),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
