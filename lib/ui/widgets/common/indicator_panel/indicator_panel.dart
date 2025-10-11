import 'package:backtestx/models/price_range.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:flutter/material.dart';

class IndicatorPanel extends StatelessWidget {
  final IndicatorType type;
  final List<double?> values;
  final List<double?>? additionalLine1; // For MACD signal line
  final List<double?>? additionalLine2; // For MACD histogram
  final int totalCandles;
  final int startIndex;
  final int endIndex;

  const IndicatorPanel({
    Key? key,
    required this.type,
    required this.values,
    required this.totalCandles,
    this.additionalLine1,
    this.additionalLine2,
    this.startIndex = 0,
    int? endIndex,
  })  : endIndex = endIndex ?? totalCandles,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              _getTitle(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: type == IndicatorType.macd
                  ? MACDPainter(
                      macdLine: values,
                      signalLine: additionalLine1,
                      histogram: additionalLine2,
                      startIndex: startIndex,
                      endIndex: endIndex,
                      labelColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    )
                  : OscillatorPainter(
                      values: values,
                      type: type,
                      startIndex: startIndex,
                      endIndex: endIndex,
                      labelColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (type) {
      case IndicatorType.rsi:
        return 'RSI (14)';
      case IndicatorType.macd:
        return 'MACD (12,26,9)';
      case IndicatorType.macdSignal:
        return 'MACD Signal (9)';
      case IndicatorType.macdHistogram:
        return 'MACD Histogram';
      case IndicatorType.atr:
        return 'ATR (14)';
      case IndicatorType.sma:
        throw UnimplementedError();
      case IndicatorType.ema:
        throw UnimplementedError();
      case IndicatorType.bollingerBands:
        throw UnimplementedError();
      case IndicatorType.close:
        throw UnimplementedError();
      case IndicatorType.open:
        throw UnimplementedError();
      case IndicatorType.high:
        throw UnimplementedError();
      case IndicatorType.low:
        throw UnimplementedError();
    }
  }
}

class OscillatorPainter extends CustomPainter {
  final List<double?> values;
  final IndicatorType type;
  final int startIndex;
  final int endIndex;
  final Color labelColor;

  OscillatorPainter({
    required this.values,
    required this.type,
    required this.startIndex,
    required this.endIndex,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final visibleValues = values.sublist(
      startIndex.clamp(0, values.length),
      endIndex.clamp(0, values.length),
    );

    if (visibleValues.isEmpty) return;

    // Calculate range
    final range = _calculateRange(visibleValues);

    // Draw background and grid
    _drawGrid(canvas, size, range);

    // Draw oscillator content
    if (type == IndicatorType.macdHistogram) {
      _drawHistogramBars(canvas, size, visibleValues, range);
    } else {
      _drawLine(canvas, size, visibleValues, range);
    }

    // Draw price labels
    _drawLabels(canvas, size, range);
  }

  PriceRange _calculateRange(List<double?> data) {
    if (type == IndicatorType.rsi) {
      return PriceRange(min: 0, max: 100);
    }

    final validValues = data.where((v) => v != null).cast<double>().toList();
    if (validValues.isEmpty) {
      return PriceRange(min: 0, max: 100);
    }

    double min = validValues.reduce((a, b) => a < b ? a : b);
    double max = validValues.reduce((a, b) => a > b ? a : b);

    // Add padding
    final padding = (max - min) * 0.1;
    return PriceRange(min: min - padding, max: max + padding);
  }

  void _drawGrid(Canvas canvas, Size size, PriceRange range) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    final chartWidth = size.width - 60; // Reserve space for labels

    // Horizontal lines
    for (int i = 0; i <= 4; i++) {
      final y = (i * size.height / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(chartWidth, y),
        gridPaint,
      );
    }

    // Special lines for RSI (30, 50, 70)
    if (type == IndicatorType.rsi) {
      final oversoldPaint = Paint()
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      final oversoldY = size.height -
          ((30 - range.min) / (range.max - range.min) * size.height);
      final overboughtY = size.height -
          ((70 - range.min) / (range.max - range.min) * size.height);
      final midY = size.height -
          ((50 - range.min) / (range.max - range.min) * size.height);

      // Oversold line (30)
      canvas.drawLine(
        Offset(0, oversoldY),
        Offset(chartWidth, oversoldY),
        oversoldPaint..color = Colors.red.withValues(alpha: 0.5),
      );

      // Mid line (50)
      canvas.drawLine(
        Offset(0, midY),
        Offset(chartWidth, midY),
        oversoldPaint..color = Colors.grey.withValues(alpha: 0.5),
      );

      // Overbought line (70)
      canvas.drawLine(
        Offset(0, overboughtY),
        Offset(chartWidth, overboughtY),
        oversoldPaint..color = Colors.red.withValues(alpha: 0.5),
      );
    }
  }

  void _drawLine(
      Canvas canvas, Size size, List<double?> data, PriceRange range) {
    final linePaint = Paint()
      ..color = _getLineColor()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool pathStarted = false;
    final candleWidth = (size.width - 60) / data.length;

    for (int i = 0; i < data.length; i++) {
      if (data[i] == null) continue;

      final x = (i + 0.5) * candleWidth;
      final y = size.height -
          ((data[i]! - range.min) / (range.max - range.min) * size.height);

      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Fill area for RSI
    if (type == IndicatorType.rsi && pathStarted) {
      final fillPath = Path.from(path);
      fillPath.lineTo((data.length - 0.5) * candleWidth, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..color = _getLineColor().withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }
  }

  void _drawHistogramBars(
      Canvas canvas, Size size, List<double?> data, PriceRange range) {
    final chartWidth = size.width - 60;
    final candleWidth = chartWidth / data.length;
    final zeroY =
        size.height - ((0 - range.min) / (range.max - range.min) * size.height);

    for (int i = 0; i < data.length; i++) {
      final v = data[i];
      if (v == null) continue;

      final xCenter = (i + 0.5) * candleWidth;
      final yValue = size.height -
          ((v - range.min) / (range.max - range.min) * size.height);

      final left = xCenter - (candleWidth * 0.35);
      final right = xCenter + (candleWidth * 0.35);
      final top = v >= 0 ? yValue : zeroY;
      final bottom = v >= 0 ? zeroY : yValue;

      final barPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = v >= 0
            ? Colors.green.withValues(alpha: 0.7)
            : Colors.red.withValues(alpha: 0.7);

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), barPaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, PriceRange range) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    final step = (range.max - range.min) / 4;
    for (int i = 0; i <= 4; i++) {
      final value = range.min + (i * step);
      final y = size.height - (i * size.height / 4);

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(type == IndicatorType.rsi ? 0 : 2),
        style: TextStyle(color: labelColor, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - 50, y - 6));
    }
  }

  Color _getLineColor() {
    switch (type) {
      case IndicatorType.rsi:
        return Colors.purple;
      case IndicatorType.atr:
        return Colors.orange;
      case IndicatorType.macd:
        return Colors.blue;
      case IndicatorType.macdSignal:
        return Colors.red;
      case IndicatorType.macdHistogram:
        return Colors.green;
      case IndicatorType.sma:
        throw UnimplementedError();
      case IndicatorType.ema:
        throw UnimplementedError();
      case IndicatorType.bollingerBands:
        throw UnimplementedError();
      case IndicatorType.close:
        throw UnimplementedError();
      case IndicatorType.open:
        throw UnimplementedError();
      case IndicatorType.high:
        throw UnimplementedError();
      case IndicatorType.low:
        throw UnimplementedError();
    }
  }

  @override
  bool shouldRepaint(OscillatorPainter oldDelegate) {
    return oldDelegate.startIndex != startIndex ||
        oldDelegate.endIndex != endIndex;
  }
}

class MACDPainter extends CustomPainter {
  final List<double?> macdLine;
  final List<double?>? signalLine;
  final List<double?>? histogram;
  final int startIndex;
  final int endIndex;
  final Color labelColor;

  MACDPainter({
    required this.macdLine,
    this.signalLine,
    this.histogram,
    required this.startIndex,
    required this.endIndex,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final visibleMacd = macdLine.sublist(
      startIndex.clamp(0, macdLine.length),
      endIndex.clamp(0, macdLine.length),
    );

    List<double?>? visibleSignal;
    List<double?>? visibleHistogram;

    if (signalLine != null) {
      visibleSignal = signalLine!.sublist(
        startIndex.clamp(0, signalLine!.length),
        endIndex.clamp(0, signalLine!.length),
      );
    }

    if (histogram != null) {
      visibleHistogram = histogram!.sublist(
        startIndex.clamp(0, histogram!.length),
        endIndex.clamp(0, histogram!.length),
      );
    }

    if (visibleMacd.isEmpty) return;

    // Calculate range
    final range =
        _calculateRange([visibleMacd, visibleSignal, visibleHistogram]);

    // Draw grid
    _drawGrid(canvas, size, range);

    // Draw histogram first (background)
    if (visibleHistogram != null) {
      _drawHistogram(canvas, size, visibleHistogram, range);
    }

    // Draw MACD line
    _drawLine(canvas, size, visibleMacd, range, Colors.blue, 1);

    // Draw Signal line
    if (visibleSignal != null) {
      _drawLine(canvas, size, visibleSignal, range, Colors.red, 1);
    }

    // Draw labels
    _drawLabels(canvas, size, range);
  }

  PriceRange _calculateRange(List<List<double?>?> allData) {
    final allValues = <double>[];

    for (final data in allData) {
      if (data != null) {
        allValues.addAll(data.where((v) => v != null).cast<double>());
      }
    }

    if (allValues.isEmpty) {
      return PriceRange(min: -0.01, max: 0.01);
    }

    double min = allValues.reduce((a, b) => a < b ? a : b);
    double max = allValues.reduce((a, b) => a > b ? a : b);

    // Add padding
    final padding = (max - min) * 0.2;
    return PriceRange(min: min - padding, max: max + padding);
  }

  void _drawGrid(Canvas canvas, Size size, PriceRange range) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Horizontal lines
    for (int i = 0; i <= 4; i++) {
      final y = (i * size.height / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width - 60, y),
        gridPaint,
      );
    }

    // Zero line
    final zeroY =
        size.height - ((0 - range.min) / (range.max - range.min) * size.height);
    if (zeroY >= 0 && zeroY <= size.height) {
      canvas.drawLine(
        Offset(0, zeroY),
        Offset(size.width - 60, zeroY),
        Paint()
          ..color = Colors.grey[600]!
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawHistogram(
      Canvas canvas, Size size, List<double?> data, PriceRange range) {
    final candleWidth = (size.width - 60) / data.length;
    final barWidth = candleWidth * 0.6;

    for (int i = 0; i < data.length; i++) {
      if (data[i] == null) continue;

      final value = data[i]!;
      final x = (i + 0.5) * candleWidth;
      final zeroY = size.height -
          ((0 - range.min) / (range.max - range.min) * size.height);
      final valueY = size.height -
          ((value - range.min) / (range.max - range.min) * size.height);

      final barPaint = Paint()
        ..color = value >= 0 ? Colors.green : Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          x - barWidth / 2,
          value >= 0 ? valueY : zeroY,
          barWidth,
          (valueY - zeroY).abs(),
        ),
        barPaint,
      );
    }
  }

  void _drawLine(Canvas canvas, Size size, List<double?> data, PriceRange range,
      Color color, double strokeWidth) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool pathStarted = false;
    final candleWidth = (size.width - 60) / data.length;

    for (int i = 0; i < data.length; i++) {
      if (data[i] == null) continue;

      final x = (i + 0.5) * candleWidth;
      final y = size.height -
          ((data[i]! - range.min) / (range.max - range.min) * size.height);

      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  void _drawLabels(Canvas canvas, Size size, PriceRange range) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    final step = (range.max - range.min) / 4;
    for (int i = 0; i <= 4; i++) {
      final value = range.min + (i * step);
      final y = size.height - (i * size.height / 4);

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(4),
        style: TextStyle(color: labelColor, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - 55, y - 6));
    }
  }

  @override
  bool shouldRepaint(MACDPainter oldDelegate) {
    return oldDelegate.startIndex != startIndex ||
        oldDelegate.endIndex != endIndex;
  }
}
