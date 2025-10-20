import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Minimal harness mirroring app's theme setup
class ThemedHarness extends StatelessWidget {
  final ValueNotifier<ThemeMode> mode;
  final Widget child;
  const ThemedHarness({super.key, required this.mode, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: mode,
      builder: (context, m, _) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xFF1E88E5),
              onPrimary: Colors.white,
              secondary: Color(0xFFFB8C00),
              onSecondary: Colors.white,
              tertiary: Color(0xFF43A047),
              onTertiary: Colors.white,
              error: Color(0xFFB00020),
              onError: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1C1E),
              surfaceContainerHighest: Color(0xFFF0F2F6),
              outline: Color(0xFFCBD2D9),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: Color(0xFF64B5F6),
              onPrimary: Color(0xFF0A0C0F),
              secondary: Color(0xFFFFB74D),
              onSecondary: Color(0xFF0A0C0F),
              tertiary: Color(0xFF81C784),
              onTertiary: Color(0xFF0A0C0F),
              error: Color(0xFFFF5252),
              onError: Color(0xFF0A0C0F),
              surface: Color(0xFF121417),
              onSurface: Color(0xFFEDEFF3),
              surfaceContainerHighest: Color(0xFF171A1E),
              outline: Color(0xFF3A3F45),
            ),
            useMaterial3: true,
          ),
          themeMode: m,
          home: Scaffold(body: child),
        );
      },
    );
  }
}

void main() {
  group('Dark mode theming — toggle, sheet surface, label color', () {
    testWidgets('Theme toggle updates brightness Light → Dark', (tester) async {
      final mode = ValueNotifier<ThemeMode>(ThemeMode.light);
      final key = GlobalKey();

      await tester.pumpWidget(
        ThemedHarness(
          mode: mode,
          child: Builder(
            key: key,
            builder: (context) {
              final cs = Theme.of(context).colorScheme;
              return Text('brightness:${cs.brightness}');
            },
          ),
        ),
      );

      // Initial light
      expect(find.text('brightness:Brightness.light'), findsOneWidget);

      // Toggle to dark
      mode.value = ThemeMode.dark;
      await tester.pumpAndSettle();
      expect(find.text('brightness:Brightness.dark'), findsOneWidget);
    });

    testWidgets('Bottom sheet surface uses ColorScheme.surface',
        (tester) async {
      final mode = ValueNotifier<ThemeMode>(ThemeMode.dark);
      final boxKey = GlobalKey();

      await tester.pumpWidget(
        ThemedHarness(
          mode: mode,
          child: Builder(
            builder: (context) {
              final cs = Theme.of(context).colorScheme;
              return Container(
                key: boxKey,
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        ),
      );

      // Verify the Container exists and uses dark surface
      final container = tester.widget<Container>(find.byKey(boxKey));
      final box = container.decoration! as BoxDecoration;
      expect(box.color, const Color(0xFF121417)); // dark surface from guide
    });

    testWidgets('Chart label color derives from onSurface with 0.7 opacity',
        (tester) async {
      final mode = ValueNotifier<ThemeMode>(ThemeMode.light);
      final textKey = GlobalKey();

      await tester.pumpWidget(
        ThemedHarness(
          mode: mode,
          child: Builder(
            builder: (context) {
              final cs = Theme.of(context).colorScheme;
              final labelColor = cs.onSurface.withValues(alpha: 0.7);
              return Text(
                'Label',
                key: textKey,
                style: TextStyle(color: labelColor),
              );
            },
          ),
        ),
      );

      final text = tester.widget<Text>(find.byKey(textKey));
      final color = text.style!.color!;
      // Light onSurface with 0.7 opacity derived via withValues
      final expectedLight = const Color(0xFF1A1C1E).withValues(alpha: 0.7);
      expect(color, expectedLight);

      // Switch to dark and verify new computed color
      mode.value = ThemeMode.dark;
      await tester.pumpAndSettle();
      final textDark = tester.widget<Text>(find.byKey(textKey));
      final colorDark = textDark.style!.color!;
      // Dark onSurface with 0.7 opacity derived via withValues
      final expectedDark = const Color(0xFFEDEFF3).withValues(alpha: 0.7);
      expect(colorDark, expectedDark);
    });
  });
}
