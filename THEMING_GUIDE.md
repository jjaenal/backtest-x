# Theming Guide

This guide standardizes how we use Flutter’s `ThemeData` and `ColorScheme` across the app to ensure consistent dark/light behavior.

## Principles

- Prefer `Theme.of(context).colorScheme` over `Colors.*`.
- Keep semantic colors (bullish/bearish/warn) but apply low-opacity backgrounds and outlined borders.
- Pass `BuildContext` to helpers that need theme tokens; do not hardcode colors.
- Use `onSurface` for text and adjust emphasis via opacity.

## Common Tokens

- Text primary: `colorScheme.onSurface`
- Muted text: `onSurface.withOpacity(0.6–0.8)`
- Icons: `onSurface` or `primary` when active
- Cards/sheets: `colorScheme.surface` or `surfaceVariant`
- Outlines/dividers: `colorScheme.outline`
- Success/Error/Warning: `primary/tertiary/error` with low-opacity fills

## Patterns

### Bottom Sheets

```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
    ),
  ),
);
```

### Text Emphasis

```dart
Text(
  description,
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
  ),
);
```

### Active Icon

```dart
Icon(
  Icons.info_outline,
  color: Theme.of(context).colorScheme.primary,
);
```

### Chart Labels / Grid

```dart
final cs = Theme.of(context).colorScheme;
final gridColor = cs.outline.withOpacity(0.2);
final labelColor = cs.onSurface.withOpacity(0.7);
```

## Do / Don’t

- Do use `ColorScheme` consistently; don’t mix raw `Colors.*` for UI surfaces.
- Do adjust opacity for subtlety; don’t use different hardcoded grays for text.
- Do accept `BuildContext` in helpers; don’t instantiate `ThemeData` directly.
- Do keep semantic mapping centralized; don’t scatter color constants.

## Migration Checklist

- Replace `Colors.white/black` surfaces with `colorScheme.surface`.
- Replace text with `onSurface` + opacity.
- Swap manual dividers with `colorScheme.outline`.
- Review icons and active states to use `primary` or `onSurface`.

## References

- Flutter Material 3: `ColorScheme`
- App README: Theming Quick Reference