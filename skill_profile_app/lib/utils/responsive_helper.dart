import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints
  static double mobile = 600;
  static double tablet = 900;
  static double desktop = 1200;

  // Check device type
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  // Get grid columns based on screen width
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobile) return 2;
    if (width < tablet) return 3;
    if (width < desktop) return 4;
    return 5;
  }

  // Get content max width
  static double getMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktop) return 1200;
    return width;
  }

  // Get horizontal padding
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 48;
    if (isTablet(context)) return 32;
    return 24;
  }

  // Get child aspect ratio for grid
  static double getChildAspectRatio(BuildContext context) {
    if (isDesktop(context)) return 0.75;
    if (isTablet(context)) return 0.7;
    return 0.55;
  }
}
