import 'dart:math';

import 'package:backtestx/app/app.locator.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const double _tinySize = 5.0;
const double _smallSize = 10.0;
const double _mediumSize = 25.0;
const double _largeSize = 50.0;
const double _massiveSize = 120.0;

const Widget horizontalSpaceTiny = SizedBox(width: _tinySize);
const Widget horizontalSpaceSmall = SizedBox(width: _smallSize);
const Widget horizontalSpaceMedium = SizedBox(width: _mediumSize);
const Widget horizontalSpaceLarge = SizedBox(width: _largeSize);

const Widget verticalSpaceTiny = SizedBox(height: _tinySize);
const Widget verticalSpaceSmall = SizedBox(height: _smallSize);
const Widget verticalSpaceMedium = SizedBox(height: _mediumSize);
const Widget verticalSpaceLarge = SizedBox(height: _largeSize);
const Widget verticalSpaceMassive = SizedBox(height: _massiveSize);

Widget spacedDivider = const Column(
  children: <Widget>[
    verticalSpaceMedium,
    Divider(color: Colors.blueGrey, height: 5.0),
    verticalSpaceMedium,
  ],
);

Widget verticalSpace(double height) => SizedBox(height: height);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightFraction(
  BuildContext context, {
  int dividedBy = 1,
  double offsetBy = 0,
  double max = 3000,
}) =>
    min((screenHeight(context) - offsetBy) / dividedBy, max);

double screenWidthFraction(
  BuildContext context, {
  int dividedBy = 1,
  double offsetBy = 0,
  double max = 3000,
}) =>
    min((screenWidth(context) - offsetBy) / dividedBy, max);

double halfScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 2);

double thirdScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 3);

double quarterScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 4);

double getResponsiveHorizontalSpaceMedium(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 10);
double getResponsiveSmallFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 14, max: 15);

double getResponsiveMediumFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 16, max: 17);

double getResponsiveLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 21, max: 31);

double getResponsiveExtraLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 25);

double getResponsiveMassiveFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 30);

double getResponsiveFontSize(
  BuildContext context, {
  double? fontSize,
  double? max,
}) {
  max ??= 100;

  var responsiveSize = min(
    screenWidthFraction(context, dividedBy: 10) * ((fontSize ?? 100) / 100),
    max,
  );

  return responsiveSize;
}

enum SnackbarType { undo, withIcon, error }

void setupSnackbarUi() {
  final service = locator<SnackbarService>();

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.undo,
    config: SnackbarConfig(
      snackPosition: SnackPosition.BOTTOM,
      closeSnackbarOnMainButtonTapped: true,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      borderRadius: 12,
    ),
  );

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.withIcon,
    config: SnackbarConfig(
      icon: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: FaIcon(
          FontAwesomeIcons.solidCircleCheck,
          color: Colors.amberAccent,
          size: 18,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      closeSnackbarOnMainButtonTapped: true,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      backgroundColor: Colors.white,
      textColor: Colors.grey.shade700,
      borderRadius: 24,
      mainButtonTextColor: Colors.blue.shade500,
    ),
  );

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.error,
    config: SnackbarConfig(
      icon: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: FaIcon(
          FontAwesomeIcons.circleXmark,
          color: Colors.red.shade500,
          size: 18,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      closeSnackbarOnMainButtonTapped: true,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      borderRadius: 24,
      mainButtonTextColor: Colors.blue.shade500,
    ),
  );
}

/// Helper to show error-styled snackbar with a retry action
typedef ShowCustomSnackBar = void Function({
  dynamic variant,
  String? title,
  String? message,
  String? mainButtonTitle,
  VoidCallback? onMainButtonTapped,
  Duration? duration,
});

void showErrorWithRetry({
  String title = 'Terjadi error',
  required String message,
  required VoidCallback onRetry,
  ShowCustomSnackBar? customShowFn,
}) {
  // Lightweight telemetry: log show and retry taps
  debugPrint('[Telemetry] Error snackbar shown: $title | $message');
  onTap() {
    debugPrint('[Telemetry] Retry tapped for: $title');
    try {
      onRetry();
    } catch (e) {
      debugPrint('[Telemetry] Retry handler error: $e');
    }
  }

  if (customShowFn != null) {
    customShowFn(
      variant: SnackbarType.error,
      title: title,
      message: message,
      mainButtonTitle: 'Coba lagi',
      onMainButtonTapped: onTap,
      duration: const Duration(seconds: 3),
    );
  } else {
    final service = locator<SnackbarService>();
    service.showCustomSnackBar(
      variant: SnackbarType.error,
      title: title,
      message: message,
      mainButtonTitle: 'Coba lagi',
      onMainButtonTapped: onTap,
      duration: const Duration(seconds: 3),
    );
  }
}
