import 'package:authentication/auth_repository.dart';
import 'package:authentication/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/utils/transitions_builder.dart';
import 'package:life_calendar/utils/utility_functions.dart';
import 'package:life_calendar/utils/utility_variables.dart';
import 'package:life_calendar/views/calendar/calendar_widget.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/views/calendar/week_info.dart';
import 'package:life_calendar/views/drawer.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  final CalendarController controller = getIt<CalendarController>();
  final _searchDateFormKey = GlobalKey<FormFieldState>();
  final TextEditingController _dateTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    debugPrint('build CalendarScreen');
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
      child: BlocProvider(
        create: (context) => AuthBloc(authRepository: getIt.get<AuthRepository>()),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Календарь жизни'),
            titleSpacing: 0,
            automaticallyImplyLeading: true,
            actions: [
              IconButton(
                onPressed: () async {
                  DateTime? searchDate;
                  await showDialog<DateTime>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Поиск недели'),
                        content: TextFormField(
                          key: _searchDateFormKey,
                          controller: _dateTimeController,
                          keyboardType: TextInputType.datetime,
                          inputFormatters: [dateMaskFormatter],
                          decoration: InputDecoration(
                            hintText: 'ДД.ММ.ГГГГ',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () async {
                                DateTime? pickedDateTime = await selectDateTimeInCalendar(context, initialDate: DateTime.now());
                                if (pickedDateTime != null) {
                                  _dateTimeController.text = formatDate(pickedDateTime);
                                  searchDate = pickedDateTime;
                                }
                              },
                            ),
                          ),
                          validator: (String? dateTime) {
                            if (dateTime != null && dateTime.isNotEmpty) {
                              DateTime? convertedDateTime = convertStringToDateTime(dateTime, firstDate: controller.birthday, lastDate: controller.lastDay);
                              if (convertedDateTime == null) {
                                return 'Недопустимое значение';
                              }
                              return null;
                            } else {
                              return 'Введите дату и время';
                            }
                          },
                          onSaved: (String? date) async {
                            if (date != null) {
                              searchDate = convertStringToDateTime(date);
                            }
                          },
                          onFieldSubmitted: (String? date) {
                            if (_searchDateFormKey.currentState!.validate()) {
                              searchDate = convertStringToDateTime(date!);
                            }
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (_searchDateFormKey.currentState!.validate()) {
                                _searchDateFormKey.currentState!.save();
                                if (searchDate != null) {
                                  Week? foundWeek = controller.findWeekByDate(searchDate!);
                                  if (foundWeek != null) {
                                    controller.selectWeek(foundWeek.id);
                                    Navigator.pop(context);

                                    await Navigator.push(context, PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => WeekInfo(),
                                      transitionsBuilder: ScreenTransition.fadeTransition,
                                    )).then((value) => controller.changedWeekId.value = foundWeek.id);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неделя не найдена')));
                                  }
                                }
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
          drawer: const SafeArea(
            child: AppDrawer(),
          ),
          body: InteractiveViewer(
            maxScale: 5,
            child: const SafeArea(
              child: CalendarWidget(),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Перейти к текущей неделе',
            onPressed: () {
              var week = controller.currentWeek;
              controller.selectWeek(week.id);

              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => WeekInfo(),
                transitionsBuilder: ScreenTransition.fadeTransition,
              ));
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.location_searching),
          ),
        ),
      ),
    );
  }
}
