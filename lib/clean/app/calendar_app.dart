import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:life_calendar/clean/features/auth/data/repositories/user_repository.dart';
import 'package:life_calendar/clean/features/calendar/data/repositories/week_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/clean/features/calendar/domain/usecases/build_calendar.dart';
import 'package:life_calendar/clean/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:life_calendar/clean/features/calendar/presentation/widgets/calendar_screen.dart';

class CalendarApp extends StatelessWidget {
  const CalendarApp({
    super.key,
    required UserRepository userRepository,
    required WeekRepository weekRepository,
  })  : _userRepository = userRepository,
        _weekRepository = weekRepository;

  final UserRepository _userRepository;
  final WeekRepository _weekRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _userRepository),
        RepositoryProvider.value(value: _weekRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => CalendarBloc(
              buildCalendar: BuildCalendar(_userRepository, _weekRepository),
            )..add(const CalendarBuildRequested()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Календарь жизни',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
          ],
          // theme: lightTheme,
          // darkTheme: darkTheme,
          routes: {
            '/': (context) => const CalendarScreen(),
            // '/datePicker': (context) => const OnBoardingScreen(),
            // '/weekInfo': (context) => const WeekInfo(),
            // '/thanks': (context) => const ThanksScreen(),
          },
          // initialRoute: firstTime ? '/datePicker' : '/',
          // initialRoute: '/datePicker',
        ),
      ),
    );
  }
}
