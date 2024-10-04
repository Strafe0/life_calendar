import 'package:flutter/material.dart';
import 'package:life_calendar/logger.dart';
import 'package:life_calendar/setup.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:life_calendar/theme.dart';
import 'package:life_calendar/views/calendar/calendar_screen.dart';
import 'package:life_calendar/views/week/week_info.dart';
import 'package:life_calendar/views/onboarding.dart';
import 'package:life_calendar/views/thanks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_calendar/models/calendar_model.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';

bool firstTime = true;

Future main() async {
  logger.i("Start app", time: DateTime.now());
  WidgetsFlutterBinding.ensureInitialized();
  await setup();

  final prefs = await SharedPreferences.getInstance();
  final bool? firstLaunch = prefs.getBool('firstTime');
  final int? birthday = prefs.getInt('birthday');

  if (firstLaunch == false && birthday != null) {
    firstTime = false;
    getIt<CalendarModel>().selectedBirthday = DateTime.fromMillisecondsSinceEpoch(birthday);
    await getIt<CalendarModel>().buildCalendar(firstTime);
  }

  MobileAds.initialize().whenComplete(() => logger.i('MobileAds initialized'));
  const String appMetricaKey = String.fromEnvironment("appmetrica_key");
  if (appMetricaKey.isNotEmpty) {
    AppMetrica.activate(const AppMetricaConfig(appMetricaKey)).then((value) => AppMetrica.reportEvent('AppMetrica activated!'));
  }
  runApp(const LifeCalendar());
}

class LifeCalendar extends StatelessWidget {
  const LifeCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      theme: lightTheme,
      darkTheme: darkTheme,
      routes: {
        '/': (context) => const CalendarScreen(),
        '/datePicker': (context) => const OnBoardingScreen(),
        '/weekInfo': (context) => const WeekInfo(),
        '/thanks': (context) => const ThanksScreen(),
      },
      initialRoute: firstTime ? '/datePicker' : '/',
      // initialRoute: '/datePicker',
    );
  }
}
