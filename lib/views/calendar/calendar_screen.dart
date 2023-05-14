import 'package:flutter/material.dart';
import 'package:life_calendar/views/calendar/calendar_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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
    );
  }
}
