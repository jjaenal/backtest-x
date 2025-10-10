import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:backtestx/ui/common/branding.dart';

import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = Branding.backgroundGradientColors(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Subtle brand pattern motif overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BrandPatternPainter(isDark: isDark),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo + title animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glow animation for logo card
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 18),
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.easeOutCubic,
                            builder: (context, glow, child) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(isDark ? 0.22 : 0.18),
                                    blurRadius: glow,
                                    spreadRadius: glow * 0.12,
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                            child: Image.asset(
                              'assets/images/png/tuangkang-logo.png',
                              width: 120,
                              height: 120,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Gradient-themed title text
                          ShaderMask(
                            shaderCallback: (Rect bounds) =>
                                Branding.horizontalPrimaryGradientShader(
                                    context, bounds),
                            child: const Text(
                              'Backtest‑X',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          // Animated accent divider under title
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 64),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOut,
                            builder: (context, w, _) => Container(
                              width: w,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Animated tagline: fade-in with slight slide-up
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      builder: (context, t, child) => Opacity(
                        opacity: 0.9 * t,
                        child: Transform.translate(
                          offset: Offset(0, (1 - t) * 8),
                          child: child,
                        ),
                      ),
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) =>
                            Branding.horizontalPrimaryGradientShader(
                                context, bounds),
                        child: const Text(
                          'Analyze • Backtest • Optimize',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _CandlesLoader(),
                    const SizedBox(height: 20),
                    // Centered per-step animation (tanpa loader atau ikon check)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      reverseDuration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final fade = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        );
                        final slide = Tween<Offset>(
                          begin: const Offset(0, 0.18),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ));
                        return FadeTransition(
                          opacity: fade,
                          child: SlideTransition(
                            position: slide,
                            child: child,
                          ),
                        );
                      },
                      child: Builder(
                        key: ValueKey(viewModel.completedSteps),
                        builder: (_) {
                          final idx = viewModel.completedSteps <
                                  viewModel.startupSteps.length
                              ? viewModel.completedSteps
                              : -1;
                          if (idx >= 0) {
                            return Row(
                              key: ValueKey('step-$idx'),
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${viewModel.startupSteps[idx]}  (${idx + 1}/${viewModel.startupSteps.length})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              key: const ValueKey('steps-done'),
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Semua langkah selesai. Menyiapkan aplikasi…',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: 0.7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '© Backtest‑X ${viewModel.appVersion}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              kReleaseMode ? 'Prod' : 'Dev',
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(isDark ? 0.22 : 0.18),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 0),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) => SchedulerBinding.instance
      .addPostFrameCallback((timeStamp) => viewModel.runStartupLogic());
}

class _CandlesLoader extends StatelessWidget {
  const _CandlesLoader();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(milliseconds: 500), (i) => i),
      builder: (context, snapshot) {
        final tick = (snapshot.data ?? 0) % 3;
        final heights = [16.0, 24.0, 12.0];
        heights[tick] += 6; // pulse active candle

        return SizedBox(
          width: 80,
          height: 32,
          child: CustomPaint(
            painter: _CandlesPainter(
              heights: heights,
              color: primary,
            ),
          ),
        );
      },
    );
  }
}

class _CandlesPainter extends CustomPainter {
  final List<double> heights;
  final Color color;

  _CandlesPainter({required this.heights, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    final candleWidth = 10.0;
    final gap = 12.0;
    for (var i = 0; i < heights.length; i++) {
      final x = (w - (candleWidth * 3 + gap * 2)) / 2 + i * (candleWidth + gap);
      final ch = heights[i];
      final y = (h - ch) / 2;
      // body
      final rect = Rect.fromLTWH(x, y, candleWidth, ch);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
      // wick
      final wickX = x + candleWidth / 2;
      canvas.drawRect(
        Rect.fromLTWH(wickX - 0.75, y - 6, 1.5, 6),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH(wickX - 0.75, y + ch, 1.5, 6),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlesPainter oldDelegate) {
    return oldDelegate.heights != heights || oldDelegate.color != color;
  }
}

class _BrandPatternPainter extends CustomPainter {
  final bool isDark;
  _BrandPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = (isDark ? Colors.white : Colors.black).withOpacity(0.05);
    final paint = Paint()
      ..color = baseColor
      ..strokeWidth = 1;

    const gridSize = 24.0;
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BrandPatternPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
