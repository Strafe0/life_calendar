import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/core/logger/crashlytics_navigation_observer.dart';
import 'package:life_calendar/core/navigation/app_routes.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/bloc/calendar_cubit.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/calendar_screen.dart';
import 'package:life_calendar/ui/calendar/week_screen/bloc/week_cubit.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_screen.dart';
import 'package:life_calendar/ui/core/dialogs/alert_dialog.dart';
import 'package:life_calendar/ui/core/dialogs/dialog_action.dart';
import 'package:life_calendar/ui/feedback/feedback_screen.dart';
import 'package:life_calendar/ui/onboarding/widgets/onboarding_screen.dart';
import 'package:life_calendar/ui/splash/widgets/error_splash_screen.dart';
import 'package:life_calendar/ui/splash/widgets/splash_screen.dart';

final goRouter = GoRouter(
  observers: [CrashlyticsNavigationObserver()],
  routes: [
    GoRoute(
      path: AppRoute.root,
      name: 'SplashScreen',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => BlocProvider(
        create: (_) => CalendarCubit(
          weekRepository: context.read(),
          settingsRepository: context.read(),
          homeWidgetService: context.read(),
        ),
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppRoute.calendar,
          name: 'CalendarScreen',
          builder: (context, state) => const CalendarScreen(),
          onExit: (context, state) async {
            final userChoice = await showAlertDialog<bool>(
              context,
              title: context.l10n.exitAppDialogTitle,
              content: context.l10n.exitAppDialogMessage,
              actions: [
                DialogAction(
                  onPressed: (context) => Navigator.of(context).pop(false),
                  title: context.l10n.buttonNo,
                ),
                DialogAction(
                  onPressed: (context) => Navigator.of(context).pop(true),
                  title: context.l10n.buttonYes,
                ),
              ],
            );

            return userChoice ?? true;
          },
          routes: [
            // add shell route for week
            GoRoute(
              path: AppRoute.week,
              name: 'WeekScreen',
              pageBuilder: (context, state) {
                final selectedWeekId = int.tryParse(
                  state.pathParameters['weekId'] ?? '',
                );

                if (selectedWeekId == null) {
                  return const MaterialPage(child: ErrorSplashScreen());
                }

                final child = BlocProvider(
                  create: (context) => WeekCubit(
                    weekRepository: context.read(),
                    analytics: context.read(),
                    homeWidgetService: context.read(),
                  )..getWeek(weekId: selectedWeekId),
                  child: WeekScreen(selectedWeekId: selectedWeekId),
                );

                if (Platform.isIOS) {
                  return CupertinoPage(key: state.pageKey, child: child);
                } else {
                  return MaterialPage(key: state.pageKey, child: child);
                }
              },
            ),
            GoRoute(
              path: AppRoute.feedback,
              name: 'FeedbackScreen',
              pageBuilder: (context, state) => Platform.isIOS
                  ? CupertinoPage(
                      key: state.pageKey,
                      child: const FeedbackScreen(),
                    )
                  : MaterialPage(
                      key: state.pageKey,
                      child: const FeedbackScreen(),
                    ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoute.onboarding,
      name: 'OnboardingScreen',
      builder: (context, state) {
        final isFull =
            bool.tryParse(state.pathParameters['isFull'] ?? 'true') ?? true;

        return OnboardingScreen(isFullOnboarding: isFull);
      },
    ),
    GoRoute(
      path: AppRoute.error,
      name: 'ErrorScreen',
      builder: (context, state) => const ErrorSplashScreen(),
    ),
  ],
);
