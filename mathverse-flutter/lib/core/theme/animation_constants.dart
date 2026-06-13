import 'package:flutter/animation.dart';

class AnimationConstants {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);

  // Curve constants
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve decelerateCurve = Curves.decelerate;
  static const Curve accelerateCurve = Curves.easeOutCubic;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve bouncyCurve = Curves.bounceOut;

  // Page transition curves
  static const Curve pageTransitionCurve = Curves.easeInOutCubic;
  static const Curve cardHoverCurve = Curves.easeInOutCubic;
  static const Curve buttonPressCurve = Curves.easeInOutCubic;

  // Animation durations for different components
  static const Duration cardHoverDuration = Duration(milliseconds: 200);
  static const Duration buttonPressDuration = Duration(milliseconds: 100);
  static const Duration fabAnimationDuration = Duration(milliseconds: 300);
  static const Duration drawerAnimationDuration = Duration(milliseconds: 300);
  static const Duration snackbarAnimationDuration = Duration(milliseconds: 300);
  static const Duration tooltipAnimationDuration = Duration(milliseconds: 300);

  // Stagger animation delays
  static const Duration staggerItemDelay = Duration(milliseconds: 50);
  static const Duration staggerSectionDelay = Duration(milliseconds: 100);
  static const Duration staggerPageDelay = Duration(milliseconds: 150);
}
