import 'package:flutter/material.dart';
import 'package:life_calendar/setup.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:life_calendar/theme.dart';
import 'package:life_calendar/views/calendar/calendar_screen.dart';
import 'package:life_calendar/views/calendar/week_info.dart';
import 'package:life_calendar/views/onboarding.dart';
import 'package:life_calendar/views/thanks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_calendar/models/calendar_model.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

bool firstTime = true;

Future main() async {
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
  MobileAds.initialize().whenComplete(() => debugPrint('MobileAds initialized'));
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
