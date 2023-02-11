import 'package:flutter/material.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';

class WeekInfo extends StatefulWidget {
  const WeekInfo({Key? key}) : super(key: key);

  @override
  State<WeekInfo> createState() => _WeekInfoState();
}

class _WeekInfoState extends State<WeekInfo> {
  final CalendarController controller = getIt<CalendarController>();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
