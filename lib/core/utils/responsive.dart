import 'package:flutter/material.dart';

class Responsive {
  const Responsive._();

  static Size sizeOf(BuildContext context) => MediaQuery.sizeOf(context);

  static double widthOf(BuildContext context) => sizeOf(context).width;

  static bool isCompact(BuildContext context) => widthOf(context) < 600;

  static bool isTablet(BuildContext context) {
    final width = widthOf(context);
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) => widthOf(context) >= 1024;

  static double horizontalPadding(BuildContext context) {
    final width = widthOf(context);
    if (width >= 1024) return 32;
    if (width >= 600) return 28;
    return 18;
  }

  static double maxContentWidth(BuildContext context) {
    final width = widthOf(context);
    if (width >= 1024) return 980;
    if (width >= 600) return 720;
    return double.infinity;
  }

  static EdgeInsets pagePadding(
    BuildContext context, {
    double top = 16,
    double bottom = 32,
  }) {
    final horizontal = horizontalPadding(context);
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }
}

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}
