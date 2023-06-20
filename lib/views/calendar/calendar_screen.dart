import 'package:flutter/material.dart';
import 'package:life_calendar/views/calendar/calendar_widget.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:life_calendar/calendar/week.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  final CalendarController controller = getIt<CalendarController>();
  final _searchDateFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Выход'),
            content: const Text('Выйти из приложения?'),
            actions: [
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                },
                child: const Text('Да'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Нет'),
              ),
            ],
          ),
        ) ?? false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Календарь жизни'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/thanks'),
              icon: Icon(Icons.handshake_outlined, color: Theme.of(context).iconTheme.color),
            ),
            IconButton(
              onPressed: () async {
                DateTime? searchDate;
                await showDialog<DateTime>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'Поиск недели',
                        // style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      content: Form(
                        key: _searchDateFormKey,
                        child: InputDatePickerFormField(
                          firstDate: controller.allYears.first.start,
                          lastDate: controller.allYears.last.end,
                          fieldHintText: 'ДД.ММ.ГГГГ',
                          onDateSaved: (DateTime? date) async {
                            searchDate = date;
                          },
                          onDateSubmitted: (DateTime? date) {
                            searchDate = date;
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () {
                            _searchDateFormKey.currentState!.save();
                            if (searchDate != null) {
                              Week foundWeek = controller.findWeekByDate(searchDate!);
                              controller.selectWeek(foundWeek.id, foundWeek.yearId);
                              Navigator.pushNamed(context, '/weekInfo').then((value) {
                                Navigator.pop(context);
                                setState(() {});
                              });
                            }
                          },
                          child: const Text('Найти'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: InteractiveViewer(
          maxScale: 5,
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
      ),
    );
  }
}
