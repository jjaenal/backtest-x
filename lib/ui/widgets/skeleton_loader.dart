import 'package:flutter/material.dart';

class SkeletonLoader {
  static Widget bar(BuildContext context,
      {double width = double.infinity,
      double height = 12,
      BorderRadius? radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceVariant
            .withValues(alpha: 0.3),
        borderRadius: radius ?? BorderRadius.circular(8),
      ),
    );
  }

  static Widget box(BuildContext context,
      {double width = double.infinity,
      double height = 80,
      BorderRadius? radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceVariant
            .withValues(alpha: 0.25),
        borderRadius: radius ?? BorderRadius.circular(12),
      ),
    );
  }

  static Widget circle(BuildContext context, {double size = 24}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceVariant
            .withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
    );
  }
}