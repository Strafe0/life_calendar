import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Builds a [SystemUiOverlayStyle] for a screen that has no [AppBar] and
/// therefore paints the surface color behind the status bar.
///
/// The status bar icons must contrast with that background, so their
/// brightness is the inverse of the surface brightness. Android reads
/// `statusBarIconBrightness` (brightness of the icons themselves) while iOS
/// reads `statusBarBrightness` (brightness of the background behind them) —
/// hence the two fields hold opposite values.
SystemUiOverlayStyle surfaceOverlayStyle(BuildContext context) {
  final brightness = ColorScheme.of(context).brightness;
  final iconBrightness = brightness == Brightness.dark
      ? Brightness.light
      : Brightness.dark;

  return SystemUiOverlayStyle(
    statusBarColor: ColorScheme.of(context).surface,
    statusBarIconBrightness: iconBrightness,
    statusBarBrightness: brightness,
  );
}
