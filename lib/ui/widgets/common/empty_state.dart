import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: cs.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (primaryLabel != null && onPrimary != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPrimary,
              icon: const Icon(Icons.add),
              label: Text(primaryLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
