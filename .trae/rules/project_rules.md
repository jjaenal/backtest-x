# Project Rules

## Tech Stack

- Dart
- Flutter
- Supabase
- gunakan `stacked` untuk membuat view, service, dialog, bottom sheet, dan widget.

## Supabase Keys

- Jangan commit API keys atau URL ke repository.
- Gunakan environment variables dan `--dart-define` untuk development.

Contoh (development):

```bash
flutter run \
  --dart-define=SUPABASE_URL=<your-url> \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

Atau gunakan file `.env` (tidak di-commit) yang kemudian di-injeksi via tooling/Makefile.

## 1. Code Quality & Linting

### Linting Process

- **WAJIB** jalankan `flutter analyze` setelah setiap perubahan kode
- **Perbaiki SEMUA** issues yang muncul:
  - ❌ Errors
  - ⚠️ Warnings
  - 📝 Info/Hints
  - 🔧 Deprecations
- **Tidak boleh** commit code yang masih ada linting issues

### Code Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Gunakan `dart format .` untuk auto-formatting sebelum commit

---

## 2. Testing

### Unit Testing Requirements

- **Setiap fungsi/method** harus punya unit test
- **Struktur test**: satu test file per source file
  - Contoh: `lib/services/auth_service.dart` → `test/services/auth_service_test.dart`
- **WAJIB** jalankan `flutter test` setelah setiap perubahan
- **Target**: Minimal 80% code coverage

### Test Checklist

- [ ] Test happy path (normal flow)
- [ ] Test edge cases
- [ ] Test error handling
- [ ] Verify semua test pass sebelum commit

---

## 3. Code Documentation

### Class Documentation

````dart
/// [AuthService] handles user authentication and session management.
///
/// This service provides methods for login, logout, and token refresh.
/// It uses Firebase Authentication as the backend.
///
/// Example:
/// ```dart
/// final authService = AuthService();
/// await authService.login(email, password);
/// ```
class AuthService {
  // ...
}
````

**Format wajib:**

- Deskripsi singkat class (satu kalimat)
- Penjelasan fungsi utama class
- Dependencies atau backend yang digunakan (jika ada)
- Contoh penggunaan (opsional, tapi recommended)

### Function/Method Documentation

```dart
/// Logs in user with [email] and [password].
///
/// Returns [User] object if login successful.
/// Throws [AuthException] if credentials invalid.
///
/// Parameters:
/// - [email]: User's email address
/// - [password]: User's password (min 6 characters)
Future<User> login(String email, String password) async {
  // ...
}
```

**Format wajib:**

- Deskripsi fungsi (satu kalimat)
- Return value (apa yang dikembalikan)
- Exceptions yang mungkin di-throw
- Parameter explanation (jika kompleks)

### Block Comment

```dart
// Validate email format before proceeding
if (!_isValidEmail(email)) {
  throw ValidationException('Invalid email format');
}

// Check if user exists in database
// If not found, create new user profile automatically
final userExists = await _checkUserExists(email);
```

**Kapan perlu block comment:**

- Logic yang kompleks/tidak obvious
- Business rules penting
- Workaround untuk bug/limitation library
- Algoritma yang perlu penjelasan

---

## 4. Git Workflow

### Branching Strategy

- **Main branch**: `main` (production-ready code)
- **Development**: `dev` (integration branch)
- **Feature branch**: `feature/<nama-fitur>` (untuk fitur baru)
- **Bugfix branch**: `bugfix/<nama-bug>` (untuk bug fixes)
- **Hotfix branch**: `hotfix/<issue>` (untuk urgent fixes di production)

**Contoh:**

- `feature/user-authentication`
- `bugfix/login-crash`
- `hotfix/payment-error`

### Commit Guidelines

#### Kapan Commit?

- Setelah menyelesaikan **satu logical change**
- Minimal 1 file, atau beberapa file yang saling terkait
- Code sudah lulus `flutter analyze` dan `flutter test`

#### Commit Message Format

```
<type>(<scope>): <subject>

<body (opsional)>
```

**Types:**

- `feat`: Fitur baru
- `fix`: Bug fix
- `refactor`: Refactor code (no functionality change)
- `docs`: Update documentation
- `test`: Tambah/update tests
- `chore`: Maintenance tasks (dependencies, config, etc)
- `style`: Formatting, missing semicolons, etc

**Contoh:**

```bash
git commit -m "feat(auth): Add Google Sign-In functionality"
git commit -m "fix(profile): Fix profile image not loading"
git commit -m "refactor(home): Simplify widget tree structure"
git commit -m "docs(readme): Update installation instructions"
```

#### Commit Checklist

- [ ] Code sudah di-format (`dart format .`)
- [ ] Linting passed (`flutter analyze`)
- [ ] Tests passed (`flutter test`)
- [ ] Documentation updated
- [ ] Commit message jelas dan deskriptif

---

## 5. Documentation Management

### TODO.md

**Update setiap kali:**

- Menyelesaikan task → Mark as done ✅
- Menemukan bug baru → Tambahkan ke list 🐛
- Ada ide improvement → Tambahkan ke backlog 💡

**Format:**

```markdown
## In Progress 🚧

- [ ] Implement user profile page

## Todo 📋

- [ ] Add dark mode support
- [ ] Integrate payment gateway

## Done ✅

- [x] Setup Firebase authentication
- [x] Create login/signup UI

## Bugs 🐛

- [ ] Profile image not updating after upload

## Future Improvements 💡

- [ ] Add biometric authentication
- [ ] Implement offline mode
```

### README.md

**Harus selalu update dengan informasi:**

````markdown
# [Project Name]

## 👨‍💻 Developer

- **Name**: [Your Name]
- **Contact**: [Email/GitHub]

## 📱 About

[Deskripsi singkat project - apa fungsinya, untuk siapa]

## 🚀 Features

- Feature 1
- Feature 2
- Feature 3

## 🛠 Tech Stack

- Flutter [version]
- Firebase Authentication
- [Other dependencies]

## 📦 Installation

```bash
flutter pub get
flutter run
```
````

## 🧪 Testing

```bash
flutter test
```

## 📁 Project Structure

```
lib/
├── app/
├── core/
├── helpers/
├── l10n/
├── models/
├── services/
├── ui/
    ├── bottom_sheets/
    ├── dialogs/
    ├── views/
    ├── widgets/
```

## 📝 Recent Changes

### [Date] - [Version]

- **Files Modified**: `auth_service.dart`, `login_screen.dart`
- **Changes**: Implemented Google Sign-In feature
- **Impact**: Users can now login with Google account

## 🐛 Known Issues

- [List any known bugs or limitations]

## 📄 License

[License information]

```

**Update README saat:**
- Menambah fitur baru (major feature)
- Mengubah project structure
- Menambah/update dependencies
- Ada breaking changes

```

## 6. Code Review Checklist

Sebelum consider task "selesai", pastikan:

- [ ] ✅ All linting issues resolved
- [ ] ✅ All tests passing
- [ ] ✅ Code documented (class, function, complex blocks)
- [ ] ✅ No commented-out code (hapus atau explain kenapa di-comment)
- [ ] ✅ No console.log/print statements (kecuali untuk debugging yang intentional)
- [ ] ✅ Error handling implemented
- [ ] ✅ TODO.md updated
- [ ] ✅ README.md updated (if needed)
- [ ] ✅ Committed with proper message
- [ ] ✅ Branch up-to-date with dev/main

## 7. Best Practices

### Performance

- Avoid unnecessary rebuilds (use `const` constructors)
- Lazy load data when possible
- Optimize image loading

### Security

- Never commit sensitive data (API keys, passwords)
- Use environment variables untuk secrets
- Validate user input

### Maintainability

- Keep functions small (max 50 lines ideally)
- Follow Single Responsibility Principle
- Avoid deep nesting (max 3-4 levels)

---

**📌 Note**: Rules ini akan di-update seiring project berkembang. Jika ada yang kurang jelas atau perlu adjustment, discuss dengan team!
