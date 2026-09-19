import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints, bool isMobile, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final mobile = width < 768;
        final tablet = width >= 768 && width < 1100;
        final desktop = width >= 1100;
        return builder(context, constraints, mobile, tablet, desktop);
      },
    );
  }
}
