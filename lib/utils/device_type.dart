import 'package:flutter/material.dart';

enum DeviceType {
  phone, tablet
}

DeviceType get deviceType {
  var view = WidgetsBinding.instance.platformDispatcher.views.first;
  double devicePixelRatio = view.devicePixelRatio;
  double shortestSide = view.physicalSize.shortestSide;

  if (shortestSide / devicePixelRatio < 550) {
    return DeviceType.phone;
  } else {
    return DeviceType.tablet;
  }
}