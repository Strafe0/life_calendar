import 'package:flutter/material.dart';
import 'package:life_calendar/views/calendar/calendar_widget.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController controller = getIt<CalendarController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь жизни в неделях'),
        automaticallyImplyLeading: false,
      ),
      body: InteractiveViewer(
        child: SafeArea(
          child: CalendarWidget(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Перейти к текущей неделе',
        child: const Icon(Icons.location_searching),
        onPressed: () {
          var week = controller.currentWeek;
          controller.selectWeek(week.id, week.yearId);
          Navigator.pushNamed(context, '/weekInfo');
        },
      ),
    );
  }
}
