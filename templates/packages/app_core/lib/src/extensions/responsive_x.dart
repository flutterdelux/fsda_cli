import 'package:flutter/material.dart';

import '../constants/app_breakpoints.dart';

extension ResponsiveX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get deviceShortestSide => MediaQuery.sizeOf(this).shortestSide;

  bool get isDesktop => screenWidth >= AppBreakpoints.desktopStart;

  bool get isTablet =>
      deviceShortestSide >= AppBreakpoints.tabletStart && !isDesktop;

  bool get isMobile => deviceShortestSide < AppBreakpoints.tabletStart;

  bool get isDesktopOrTablet {
    return deviceShortestSide >= AppBreakpoints.tabletStart ||
        screenWidth >= AppBreakpoints.desktopStart;
  }
}
