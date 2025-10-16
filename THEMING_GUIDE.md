# Theming Guide

This guide standardizes how we use Flutter’s `ThemeData` and `ColorScheme` across the app to ensure consistent dark/light behavior.

## Principles

- Prefer `Theme.of(context).colorScheme` over `Colors.*`.
- Keep semantic colors (bullish/bearish/warn) but apply low-opacity backgrounds and outlined borders.
- Pass `BuildContext` to helpers that need theme tokens; do not hardcode colors.
- Use `onSurface` for text and adjust emphasis via opacity.

## Common Tokens

- Text primary: `colorScheme.onSurface`
- Muted text: `onSurface.withValues(alpha:0.6–0.8)`
- Icons: `onSurface` or `primary` when active
- Cards/sheets: `colorScheme.surface` or `surfaceContainerHighest`
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
      color: Theme.of(context).colorScheme.outline.withValues(alpha:0.3),
    ),
  ),
);
```

### Text Emphasis

```dart
Text(
  description,
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.8),
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
final gridColor = cs.outline.withValues(alpha:0.2);
final labelColor = cs.onSurface.withValues(alpha:0.7);
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

---

## ColorScheme Map (Semantic → Tokens)

- Backgrounds: `surface`, `surfaceContainerHighest`
- Primary actions: `primary` (text: `onPrimary`)
- Success/Positive: `tertiary` (text: `onTertiary`)
- Error/Destructive: `error` (text: `onError`)
- Text (default): `onSurface` with opacity for emphasis
- Borders/Dividers: `outline`

## Token System (Recommended)

Define app-level tokens layered on top of `ColorScheme` for semantic usage:

```dart
class AppTokens {
  final ColorScheme cs;
  AppTokens(this.cs);

  // Surfaces
  Color get cardBg => cs.surface;
  Color get sheetBg => cs.surfaceContainerHighest;
  Color get border => cs.outline.withValues(alpha:0.3);

  // Text
  Color get text => cs.onSurface;
  Color get textMuted => cs.onSurface.withValues(alpha:0.7);
  Color get textSubtle => cs.onSurface.withValues(alpha:0.5);

  // States
  Color get accent => cs.primary;
  Color get success => cs.tertiary;
  Color get error => cs.error;
  Color get warning => cs.secondary;

  // Fills
  Color get successFill => cs.tertiary.withValues(alpha:0.12);
  Color get errorFill => cs.error.withValues(alpha:0.12);
  Color get warningFill => cs.secondary.withValues(alpha:0.12);
}
```

Usage pattern in widgets:

```dart
final cs = Theme.of(context).colorScheme;
final t = AppTokens(cs);

Container(
  decoration: BoxDecoration(
    color: t.cardBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: t.border),
  ),
  child: Text(
    'Example',
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.text),
  ),
);
```

## Example Palettes (Light/Dark)

These are suggested values; use Material 3 guidance and adjust to brand.

```dart
// Light
const lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF1E88E5),
  onPrimary: Colors.white,
  secondary: Color(0xFFFB8C00),
  onSecondary: Colors.white,
  tertiary: Color(0xFF43A047),
  onTertiary: Colors.white,
  error: Color(0xFFB00020),
  onError: Colors.white,
  background: Color(0xFFF6F7FB),
  onBackground: Color(0xFF1A1C1E),
  surface: Colors.white,
  onSurface: Color(0xFF1A1C1E),
  surfaceContainerHighest: Color(0xFFF0F2F6),
  outline: Color(0xFFCBD2D9),
);

// Dark
const darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF64B5F6),
  onPrimary: Color(0xFF0A0C0F),
  secondary: Color(0xFFFFB74D),
  onSecondary: Color(0xFF0A0C0F),
  tertiary: Color(0xFF81C784),
  onTertiary: Color(0xFF0A0C0F),
  error: Color(0xFFFF5252),
  onError: Color(0xFF0A0C0F),
  background: Color(0xFF0F1114),
  onBackground: Color(0xFFEDEFF3),
  surface: Color(0xFF121417),
  onSurface: Color(0xFFEDEFF3),
  surfaceContainerHighest: Color(0xFF171A1E),
  outline: Color(0xFF3A3F45),
);
```

## Integration Tips

- Build `ThemeData` from `ColorScheme`: `ThemeData.from(colorScheme: darkScheme)`.
- Keep `ThemeService` toggling `ThemeMode` only; inject schemes via `MaterialApp`.
- Theme texts via `textTheme` derived from `ColorScheme.onSurface`.
- Components:
  - Cards/Sheets: `surface/surfaceContainerHighest` + `outline` border.
  - Banners/Alerts: use fills (`errorFill`, `successFill`) with token text.
  - Charts: grid `outline.withValues(alpha:0.2)`, labels `onSurface.withValues(alpha:0.7)`.

## Component Patterns (Examples)

### Card

```dart
final t = AppTokens(Theme.of(context).colorScheme);
return Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: t.cardBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: t.border),
  ),
  child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: t.text)),
);
```

### List Item

```dart
final cs = Theme.of(context).colorScheme;
return ListTile(
  tileColor: cs.surface,
  title: Text(name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cs.onSurface)),
  subtitle: Text(desc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha:0.7))),
  trailing: Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha:0.8)),
);
```

### Banner / Alert

```dart
final t = AppTokens(Theme.of(context).colorScheme);
Widget banner(Color fill, Color iconColor, String message) => Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: fill,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: t.border),
  ),
  child: Row(children: [
    Icon(Icons.info_outline, color: iconColor),
    const SizedBox(width: 8),
    Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.text))),
    TextButton(onPressed: onRetry, child: const Text('Retry')),
  ]),
);

// Usage
banner(t.errorFill, t.error, 'Failed to load data');
```

### Chart (Grid & Labels)

```dart
final cs = Theme.of(context).colorScheme;
final gridColor = cs.outline.withValues(alpha:0.2);
final labelColor = cs.onSurface.withValues(alpha:0.7);
// Configure chart library using gridColor/labelColor consistently.
```

## Checklist (Quick)

- [ ] Audit raw `Colors.*` usage and replace with `ColorScheme`.
- [ ] Centralize semantic tokens (`AppTokens`).
- [ ] Verify contrast ratios in light/dark.
- [x] Document component patterns (cards, lists, charts, sheets).
