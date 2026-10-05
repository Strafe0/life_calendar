import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:life_calendar/core/navigation/app_routes.dart';
import 'package:life_calendar/ui/core/themes/system_overlay_style.dart';
import 'package:life_calendar/ui/splash/bloc/splash_cubit.dart';
import 'package:life_calendar/ui/splash/bloc/splash_state.dart';
import 'package:life_calendar/ui/user/bloc/user_bloc.dart';
import 'package:life_calendar/ui/user/bloc/user_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: surfaceOverlayStyle(context),
      child: BlocProvider(
        create: (context) => SplashCubit(
          appInitializer: context.read(),
          userRepository: context.read(),
          weeklyNotificationInteractor: context.read(),
          settingsRepository: context.read(),
        )..prepareApp(),
        child: Builder(
          builder: (context) {
            return BlocListener<SplashCubit, SplashState>(
              listener: (context, state) {
                switch (state) {
                  case SplashInitial():
                  case SplashLoading():
                    break;
                  case SplashReady():
                    if (state.isAuthenticated) {
                      context.read<UserBloc>().add(UserReceived(state.user));

                      if (state.isFirstLaunchV3) {
                        return context.go(
                          AppRoute.onboardingPath(isFull: false),
                        );
                      }

                      context.go(AppRoute.calendar);
                    } else {
                      context.go(AppRoute.onboarding);
                    }
                  case SplashFailure():
                    context.go(AppRoute.error);
                }
              },
              child: const Scaffold(
                body: SafeArea(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
