import 'package:life_calendar/domain/models/user/user.dart';

sealed class SplashState {
  const SplashState();
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashReady extends SplashState {
  final User user;
  final bool isFirstLaunchV3;

  const SplashReady({required this.user, required this.isFirstLaunchV3});

  bool get isAuthenticated => !user.isEmpty;
}

final class SplashFailure extends SplashState {
  const SplashFailure();
}
