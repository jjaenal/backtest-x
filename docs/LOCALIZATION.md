# Localization Guide (i18n/L10n)

This project uses manual `AppLocalizations` with ARB files as the single source of strings, mapped via camelCase getters to snake_case keys.

## Naming Convention

- Getters: camelCase (e.g., `loginContinueGoogle`)
- ARB keys: snake_case (e.g., `login_continue_google`)
- Map entries in `lib/l10n/app_localizations.dart` define readable strings per locale.

## Adding New Strings

1. Add keys to ARB files:
   - `lib/l10n/app_en.arb`
   - `lib/l10n/app_id.arb`
2. Update `lib/l10n/app_localizations.dart`:
   - Add English/Indonesian values in the language maps.
   - Add a camelCase getter mapping to the snake_case key (e.g., `String get loginContinueGithub => _text('login_continue_github');`).
3. Use the new getter in UI code.
4. Run analyzer:
   ```bash
   flutter analyze
   ```
5. Run ARB guard script:
   ```bash
   dart run tool/check_arb_consistency.dart
   ```

## Email Verification Keys

- `user_email_resend`
- `user_email_resend_success`
- `user_email_resend_error`

Ensure both `en` and `id` locales have values and getters exist.

## OAuth Labels

- `login_continue_google`
- `login_continue_github`
- `login_continue_apple`

Getters:
- `loginContinueGoogle`
- `loginContinueGithub`
- `loginContinueApple`

## Error Keys

Prefer descriptive snake_case keys in ARB, and consistent camelCase getters in `AppLocalizations`.

## Plurals & Interpolation (Future Work)

- For counts (trades, signals, wins), add structured methods or helpers to format pluralized strings.
- Consider adding `intl` with manual wrappers if needed.

## Key Consistency & Unused Keys

Use the guard script to check:
- Missing keys between `en` and `id` locales.
- Unused ARB keys (not referenced in `AppLocalizations`).

```bash
dart run tool/check_arb_consistency.dart
```

## Contribution Guidelines

- Keep strings short and clear.
- Avoid hardcoding in UI; always reference `AppLocalizations`.
- When adding keys, update both ARB files and `AppLocalizations` getters.
- Keep camelCase getters in code, and snake_case in ARB/maps.