import 'package:flutter/animation.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration instant = Duration.zero;
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 800);

  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration cardHover = Duration(milliseconds: 200);
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration shimmer = Duration(milliseconds: 1500);

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;
  static const Curve linear = Curves.linear;

  static const Curve pageTransitionCurve = Curves.easeInOut;
  static const Curve cardHoverCurve = Curves.easeOut;
  static const Curve buttonPressCurve = Curves.easeIn;
  static const Curve springCurve = Curves.fastOutSlowIn;

  static const double pageTransitionScale = 0.95;
  static const double cardHoverScale = 1.02;
  static const double buttonPressScale = 0.95;
}
