import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AppStatusBar extends StatelessWidget {
  final Color color;
  final Brightness iconBrightness;
  final Widget child;

  const AppStatusBar({
    super.key,
    required this.color,
    required this.child,
    this.iconBrightness = Brightness.dark,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: iconBrightness,
        statusBarBrightness: iconBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark, // iOS
      ),
      child: Container(color: color, child: child),
    );
  }
}
