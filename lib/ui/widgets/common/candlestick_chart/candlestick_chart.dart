import 'package:backtestx/models/candle.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CandlestickChart extends StatefulWidget {
  final List<Candle> candles;
  final List<double?>? sma;
  final List<double?>? ema;
  final Map<String, List<double?>>? bollingerBands;
  final bool showVolume;
  final String? title;
  final Function(int startIndex, int endIndex)? onRangeChanged;

  const CandlestickChart({
    Key? key,
    required this.candles,
    this.sma,
    this.ema,
    this.bollingerBands,
    this.showVolume = true,
    this.title,
    this.onRangeChanged,
  }) : super(key: key);

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  double _startIndex = 0;
  double _endIndex = 100;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    // Start from most recent candles
    const visibleCount = 100.0;
    _endIndex = widget.candles.length.toDouble();
    _startIndex = (_endIndex - visibleCount).clamp(0, _endIndex);

    // Notify parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRangeChanged?.call(_startIndex.toInt(), _endIndex.toInt());
    });
  }

  void _notifyRangeChange() {
    widget.onRangeChanged?.call(_startIndex.toInt(), _endIndex.toInt());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty) {
      return const Center(child: Text('No candle data available'));
    }

    return Column(
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        if (_hoveredIndex != null)
          _buildCandleInfo(widget.candles[_hoveredIndex!]),
        Expanded(
          flex: widget.showVolume ? 7 : 10,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                final delta = -details.delta.dx;
                final range = _endIndex - _startIndex;
                final shift = (delta / 300) * range;

                _startIndex = (_startIndex + shift)
                    .clamp(0, widget.candles.length - range);
                _endIndex = _startIndex + range;
                _notifyRangeChange();
              });
            },
            child: CustomPaint(
              painter: CandlestickPainter(
                candles: widget.candles,
                startIndex: _startIndex.toInt(),
                endIndex: _endIndex.toInt(),
                sma: widget.sma,
                ema: widget.ema,
                bollingerBands: widget.bollingerBands,
                hoveredIndex: _hoveredIndex,
              ),
              child: Container(),
            ),
          ),
        ),
        if (widget.showVolume && widget.candles.any((c) => c.volume > 0))
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: BarChart(_buildVolumeChart()),
            ),
          ),
        _buildZoomControls(),
      ],
    );
  }

  Widget _buildCandleInfo(Candle candle) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('O', candle.open),
          _buildInfoItem('H', candle.high),
          _buildInfoItem('L', candle.low),
          _buildInfoItem('C', candle.close, isBold: true),
          if (candle.volume > 0)
            _buildInfoItem('V', candle.volume, isVolume: true),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, double value,
      {bool isBold = false, bool isVolume = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          isVolume ? value.toStringAsFixed(0) : value.toStringAsFixed(4),
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  BarChartData _buildVolumeChart() {
    final visibleCandles = widget.candles.sublist(
      _startIndex.toInt().clamp(0, widget.candles.length),
      _endIndex.toInt().clamp(0, widget.candles.length),
    );

    final maxVolume = visibleCandles.isEmpty
        ? 1.0
        : visibleCandles.map((c) => c.volume).reduce((a, b) => a > b ? a : b);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxVolume * 1.2,
      minY: 0,
      barGroups: List.generate(
        visibleCandles.length,
        (index) {
          final candle = visibleCandles[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: candle.volume,
                color: candle.isBullish
                    ? Colors.green.withValues(alpha: 0.5)
                    : Colors.red.withValues(alpha: 0.5),
                width: 3,
              ),
            ],
          );
        },
      ),
      gridData: FlGridData(show: true, horizontalInterval: maxVolume / 3),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Text(_formatVolume(value),
                  style: const TextStyle(fontSize: 10));
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      barTouchData: BarTouchData(enabled: false),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.zoom_out), onPressed: _zoomOut),
          Expanded(
            child: Slider(
              value: (_endIndex - _startIndex)
                  .clamp(10, widget.candles.length.toDouble()),
              min: 10,
              max: widget.candles.length.toDouble(),
              onChanged: (value) {
                setState(() {
                  final center = (_startIndex + _endIndex) / 2;
                  _startIndex = (center - value / 2)
                      .clamp(0, widget.candles.length.toDouble());
                  _endIndex = (center + value / 2)
                      .clamp(0, widget.candles.length.toDouble());
                  _notifyRangeChange();
                });
              },
            ),
          ),
          IconButton(icon: const Icon(Icons.zoom_in), onPressed: _zoomIn),
          IconButton(icon: const Icon(Icons.fit_screen), onPressed: _resetZoom),
        ],
      ),
    );
  }

  void _zoomIn() {
    setState(() {
      final range = _endIndex - _startIndex;
      final newRange =
          (range * 0.7).clamp(10, widget.candles.length.toDouble());
      final center = (_startIndex + _endIndex) / 2;
      _startIndex =
          (center - newRange / 2).clamp(0, widget.candles.length.toDouble());
      _endIndex =
          (center + newRange / 2).clamp(0, widget.candles.length.toDouble());
      _notifyRangeChange();
    });
  }

  void _zoomOut() {
    setState(() {
      final range = _endIndex - _startIndex;
      final newRange =
          (range * 1.3).clamp(10, widget.candles.length.toDouble());
      final center = (_startIndex + _endIndex) / 2;
      _startIndex =
          (center - newRange / 2).clamp(0, widget.candles.length.toDouble());
      _endIndex =
          (center + newRange / 2).clamp(0, widget.candles.length.toDouble());
      _notifyRangeChange();
    });
  }

  void _resetZoom() {
    setState(() {
      const visibleCount = 100.0;
      _endIndex = widget.candles.length.toDouble();
      _startIndex = (_endIndex - visibleCount).clamp(0, _endIndex);
      _notifyRangeChange();
    });
  }

  String _formatVolume(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

class CandlestickPainter extends CustomPainter {
  final List<Candle> candles;
  final int startIndex;
  final int endIndex;
  final List<double?>? sma;
  final List<double?>? ema;
  final Map<String, List<double?>>? bollingerBands;
  final int? hoveredIndex;
  final double chartWidth;

  CandlestickPainter({
    required this.candles,
    required this.startIndex,
    required this.endIndex,
    this.sma,
    this.ema,
    this.bollingerBands,
    this.hoveredIndex,
    this.chartWidth = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final visibleCandles = candles.sublist(
      startIndex.clamp(0, candles.length),
      endIndex.clamp(0, candles.length),
    );

    if (visibleCandles.isEmpty) return;

    // Reserve space for price labels on right
    const labelWidth = 70.0;
    final chartArea = Size(size.width - labelWidth, size.height);

    // Calculate price range
    double minPrice = visibleCandles.first.low;
    double maxPrice = visibleCandles.first.high;
    for (final candle in visibleCandles) {
      if (candle.low < minPrice) minPrice = candle.low;
      if (candle.high > maxPrice) maxPrice = candle.high;
    }
    final priceRange = maxPrice - minPrice;
    final padding = priceRange * 0.1;
    minPrice -= padding;
    maxPrice += padding;

    final candleWidth = chartArea.width / visibleCandles.length;
    final bodyWidth = candleWidth * 0.7;

    // Draw grid
    _drawGrid(canvas, chartArea, minPrice, maxPrice);

    // Draw indicators first (behind candles)
    if (bollingerBands != null) {
      _drawBollingerBands(
          canvas, chartArea, visibleCandles, minPrice, maxPrice, candleWidth);
    }
    if (sma != null) {
      _drawIndicatorLine(
          canvas,
          chartArea,
          sma!,
          startIndex,
          visibleCandles.length,
          minPrice,
          maxPrice,
          candleWidth,
          Colors.blue,
          1);
    }
    if (ema != null) {
      _drawIndicatorLine(
          canvas,
          chartArea,
          ema!,
          startIndex,
          visibleCandles.length,
          minPrice,
          maxPrice,
          candleWidth,
          Colors.orange,
          1);
    }

    // Draw candles
    for (int i = 0; i < visibleCandles.length; i++) {
      final candle = visibleCandles[i];
      final x = (i + 0.5) * candleWidth;

      _drawCandle(
          canvas, candle, x, bodyWidth, chartArea.height, minPrice, maxPrice);
    }

    // Draw price labels (on the right side)
    _drawPriceLabels(canvas, size, chartArea, minPrice, maxPrice, labelWidth);
  }

  void _drawGrid(
      Canvas canvas, Size chartArea, double minPrice, double maxPrice) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // final priceStep = (maxPrice - minPrice) / 5;
    for (int i = 0; i <= 5; i++) {
      final y = chartArea.height - (i * chartArea.height / 5);
      canvas.drawLine(Offset(0, y), Offset(chartArea.width, y), paint);
    }
  }

  void _drawCandle(Canvas canvas, Candle candle, double x, double bodyWidth,
      double height, double minPrice, double maxPrice) {
    final priceRange = maxPrice - minPrice;

    final highY = height - ((candle.high - minPrice) / priceRange * height);
    final lowY = height - ((candle.low - minPrice) / priceRange * height);
    final openY = height - ((candle.open - minPrice) / priceRange * height);
    final closeY = height - ((candle.close - minPrice) / priceRange * height);

    final wickPaint = Paint()
      ..color = candle.isBullish ? Colors.green : Colors.red
      ..strokeWidth = 1;

    // Draw wick
    canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

    // Draw body
    final bodyPaint = Paint()
      ..color = candle.isBullish ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;

    final bodyTop = candle.isBullish ? closeY : openY;
    final bodyBottom = candle.isBullish ? openY : closeY;
    final bodyHeight = (bodyBottom - bodyTop).abs().clamp(1, height);

    canvas.drawRect(
      Rect.fromLTWH(
          x - bodyWidth / 2, bodyTop, bodyWidth, bodyHeight.toDouble()),
      bodyPaint,
    );
  }

  void _drawIndicatorLine(
      Canvas canvas,
      Size chartArea,
      List<double?> indicator,
      int offset,
      int count,
      double minPrice,
      double maxPrice,
      double candleWidth,
      Color color,
      double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final priceRange = maxPrice - minPrice;
    final path = Path();
    bool pathStarted = false;

    for (int i = 0; i < count; i++) {
      final globalIndex = offset + i;
      if (globalIndex >= indicator.length) break;

      final value = indicator[globalIndex];
      if (value == null) continue;

      final x = (i + 0.5) * candleWidth;
      final y = chartArea.height -
          ((value - minPrice) / priceRange * chartArea.height);

      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawBollingerBands(
      Canvas canvas,
      Size chartArea,
      List<Candle> visibleCandles,
      double minPrice,
      double maxPrice,
      double candleWidth) {
    if (bollingerBands == null) return;

    final upper = bollingerBands!['upper'];
    final middle = bollingerBands!['middle'];
    final lower = bollingerBands!['lower'];

    if (upper != null) {
      _drawIndicatorLine(
          canvas,
          chartArea,
          upper,
          startIndex,
          visibleCandles.length,
          minPrice,
          maxPrice,
          candleWidth,
          Colors.purple.withValues(alpha: 0.5),
          1);
    }
    if (middle != null) {
      _drawIndicatorLine(
          canvas,
          chartArea,
          middle,
          startIndex,
          visibleCandles.length,
          minPrice,
          maxPrice,
          candleWidth,
          Colors.purple,
          2);
    }
    if (lower != null) {
      _drawIndicatorLine(
          canvas,
          chartArea,
          lower,
          startIndex,
          visibleCandles.length,
          minPrice,
          maxPrice,
          candleWidth,
          Colors.purple.withValues(alpha: 0.5),
          1);
    }
  }

  void _drawPriceLabels(Canvas canvas, Size fullSize, Size chartArea,
      double minPrice, double maxPrice, double labelWidth) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    final priceStep = (maxPrice - minPrice) / 5;
    for (int i = 0; i <= 5; i++) {
      final price = minPrice + (i * priceStep);
      final y = fullSize.height - (i * fullSize.height / 5);

      textPainter.text = TextSpan(
        text: price.toStringAsFixed(4),
        style: const TextStyle(color: Colors.black, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(fullSize.width - 60, y - 6));
    }
  }

  @override
  bool shouldRepaint(CandlestickPainter oldDelegate) {
    return oldDelegate.startIndex != startIndex ||
        oldDelegate.endIndex != endIndex ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}
