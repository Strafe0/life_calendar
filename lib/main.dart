import 'package:flutter/material.dart';
import 'package:life_calendar/setup.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:life_calendar/views/date_picker_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  runApp(const LifeCalendar());
}

class LifeCalendar extends StatelessWidget {
  const LifeCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Calendar',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true)),
      // home: const MyHomePage(title: 'Календарь жизни в неделях'),
      home: const DatePickerScreen(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.only(right: 8.0),
//           child: Center(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: const [
//                       Text('Недели'),
//                       Icon(Icons.arrow_right_alt),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: const [
//                         RotatedBox(quarterTurns: -1, child: Text('Годы')),
//                         RotatedBox(quarterTurns: 1, child: Icon(Icons.arrow_right_alt)),
//                       ],
//                     ),
//                     Expanded(
//                       child: GridView.count(
//                         shrinkWrap: true,
//                         crossAxisSpacing: 1,
//                         mainAxisSpacing: 1,
//                         crossAxisCount: 52,
//                         children: List.generate(4160, (index) => index < 1251 ? const WeekBox(Colors.black45) : const WeekBox(Colors.grey)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

