import 'package:flutter/material.dart';
import 'package:backtestx/l10n/app_localizations.dart';

class DialogBuilder {
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    String? cancelLabel,
    bool isDangerous = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel ?? l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: isDangerous
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showExitConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return showConfirmationDialog(
      context,
      title: l10n.sbExitConfirmTitle,
      content: l10n.sbExitConfirmContent,
      confirmLabel: l10n.commonClose,
      isDangerous: true,
    );
  }
}
