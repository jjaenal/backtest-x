import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:backtestx/models/trade.dart';

class PdfExportService {
  Future<Uint8List> buildBacktestReport(BacktestResult result) async {
    // Use Google Noto Sans fonts to support Unicode
    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final italicFont = await PdfGoogleFonts.notoSansItalic();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
        italic: italicFont,
      ),
    );
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    final summary = result.summary;

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Backtest Report',
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                              )),
                          pw.SizedBox(height: 4),
                          pw.Text('Strategy: ${result.strategyId}',
                              style: const pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                      pw.Text(
                        'Generated: ${dateFormat.format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),

                  // Summary
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColors.grey300, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Performance Summary',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            )),
                        pw.SizedBox(height: 8),
                        _summaryRow(
                            'Total Trades', summary.totalTrades.toString()),
                        _summaryRow(
                            'Winning Trades', summary.winningTrades.toString()),
                        _summaryRow(
                            'Losing Trades', summary.losingTrades.toString()),
                        _summaryRow('Win Rate',
                            '${summary.winRate.toStringAsFixed(1)}%'),
                        _summaryRow(
                            'Total PnL', _fmtCurrencyUsd(summary.totalPnl)),
                        _summaryRow('Total PnL %',
                            '${summary.totalPnlPercentage.toStringAsFixed(2)}%'),
                        _summaryRow('Profit Factor',
                            summary.profitFactor.toStringAsFixed(2)),
                        _summaryRow('Max Drawdown',
                            _fmtCurrencyUsd(summary.maxDrawdown)),
                        _summaryRow('Max Drawdown %',
                            '${summary.maxDrawdownPercentage.toStringAsFixed(2)}%'),
                        _summaryRow('Sharpe Ratio',
                            summary.sharpeRatio.toStringAsFixed(2)),
                        _summaryRow(
                            'Average Win', _fmtCurrencyUsd(summary.averageWin)),
                        _summaryRow('Average Loss',
                            _fmtCurrencyUsd(summary.averageLoss)),
                        _summaryRow(
                            'Largest Win', _fmtCurrencyUsd(summary.largestWin)),
                        _summaryRow('Largest Loss',
                            _fmtCurrencyUsd(summary.largestLoss)),
                        _summaryRow(
                            'Expectancy', _fmtCurrencyUsd(summary.expectancy)),
                        if (summary.tfStats != null &&
                            summary.tfStats!.isNotEmpty) ...[
                          pw.SizedBox(height: 8),
                          pw.Text('Per-Timeframe Stats',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              )),
                          ...summary.tfStats!.entries.map((e) {
                            final tf = e.key;
                            final s = e.value;
                            final signals = (s['signals'] ?? 0).toInt();
                            final trades = (s['trades'] ?? 0).toInt();
                            final wins = (s['wins'] ?? 0).toInt();
                            final wr = (s['winRate'] ?? 0).toDouble();
                            final value =
                                'Signals: $signals, Trades: $trades, Wins: $wins, WinRate: ${wr.toStringAsFixed(1)}%';
                            return _summaryRow('TF $tf', value);
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Trades table
                  pw.Text('Trade History',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  ..._buildTradesTables(result),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _summaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  List<pw.Widget> _buildTradesTables(BacktestResult result) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final trades =
        result.trades.where((t) => t.status == TradeStatus.closed).toList();
    // Limit total rows and split into multiple smaller tables so each fits a page
    const maxRows = 60; // total rows cap
    const rowsPerTable = 20; // rows per table chunk to avoid overflow

    final headers = [
      'Direction',
      'Entry Date',
      'Exit Date',
      'Entry Price',
      'Exit Price',
      'PnL',
      'PnL %',
    ];

    final allRows = trades.take(maxRows).map((t) {
      return [
        t.direction == TradeDirection.buy ? 'BUY' : 'SELL',
        dateFormat.format(t.entryTime),
        t.exitTime != null ? dateFormat.format(t.exitTime!) : '-',
        t.entryPrice.toStringAsFixed(4),
        t.exitPrice?.toStringAsFixed(4) ?? '-',
        (t.pnl ?? 0).toStringAsFixed(2),
        (t.pnlPercentage ?? 0).toStringAsFixed(2),
      ];
    }).toList();

    final widgets = <pw.Widget>[];
    for (int i = 0; i < allRows.length; i += rowsPerTable) {
      final chunk = allRows.sublist(
        i,
        i + rowsPerTable > allRows.length ? allRows.length : i + rowsPerTable,
      );
      widgets.add(
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: chunk,
          headerDecoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF0F0F0),
          ),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding:
              const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.3),
        ),
      );
      if (i + rowsPerTable < allRows.length) {
        widgets.add(pw.SizedBox(height: 12));
      }
    }
    return widgets;
  }

  String _fmtCurrencyUsd(double value) {
    final f = NumberFormat.currency(symbol: '\$');
    return f.format(value);
  }
}
