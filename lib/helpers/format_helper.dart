import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class FormatHelper {
  static String formatCurrency(
    BuildContext context,
    double value, {
    String symbol = '\$',
    bool showSign = true,
    int decimalDigits = 2,
  }) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    final formatted = formatter.format(value);
    if (showSign && value >= 0) {
      return '+$formatted';
    }
    return formatted;
  }

  static String formatPercent(
    BuildContext context,
    double value, {
    bool showSign = true,
    int decimalDigits = 2,
  }) {
    final locale = Localizations.localeOf(context).toString();
    final pattern = '0.${'0' * decimalDigits}';
    final formatter = NumberFormat(pattern, locale);
    final absFormatted = formatter.format(value.abs());
    final signed = value < 0
        ? '-$absFormatted'
        : (showSign ? '+$absFormatted' : absFormatted);
    return '$signed%';
  }

  static String formatWinRate(BuildContext context, double rate,
      {int decimalDigits = 1}) {
    final locale = Localizations.localeOf(context).toString();
    final pattern = '0.${decimalDigits > 0 ? '0' * decimalDigits : ''}';
    final formatter = NumberFormat(pattern, locale);
    return '${formatter.format(rate)}%';
  }

  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date);
  }

  static String formatDateTime(
    BuildContext context,
    DateTime date, {
    String separator = ' • ',
  }) {
    final locale = Localizations.localeOf(context).toString();
    final d = DateFormat.yMMMd(locale).format(date);
    final t = DateFormat.Hm(locale).format(date);
    return '$d$separator$t';
  }
}
