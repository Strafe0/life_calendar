import 'package:flutter/material.dart';

class ScreenTransition {
  static Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) rightBottomTransition = (context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  };

  static Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) fadeTransition = (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  };
}