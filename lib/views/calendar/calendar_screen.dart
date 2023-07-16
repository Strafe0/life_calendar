import 'package:flutter/material.dart';
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
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      title: const Text(
                        'Поиск недели',
                        // style: Theme.of(context).textTheme.headlineSmall,
                      ),
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
                                Week foundWeek = controller.findWeekByDate(searchDate!);
                                controller.selectWeek(foundWeek.id, foundWeek.yearId);
                                Navigator.pop(context);

                                await Navigator.push(context, PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => WeekInfo(),
                                  transitionsBuilder: ScreenTransition.fadeTransition,
                                )).then((value) => controller.changedWeekId.value = foundWeek.id);
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
        drawer: SafeArea(
          child: Drawer(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), bottomRight: Radius.circular(16.0))),
            child: ListView(
              children: [
                DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Дата рождения", style: Theme.of(context).textTheme.titleLarge,),
                      Text("${controller.birthday.day}.${controller.birthday.month}.${controller.birthday.year}", style: Theme.of(context).textTheme.titleLarge,),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text("Связь с разработчиком"),
                  onTap: () => Navigator.pushNamed(context, '/thanks'),
                ),
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: const Text("Политика конфиденциальности"),
                  onTap: () async {
                    final Uri url = Uri.parse(privacyPolicyUrl);
                    if (!await launchUrl(url)) {
                      _showTopErrorSnackBar();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        body: InteractiveViewer(
          maxScale: 5,
          child: SafeArea(
            child: CalendarWidget(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Перейти к текущей неделе',
          onPressed: () {
            var week = controller.currentWeek;
            controller.selectWeek(week.id, week.yearId);

            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => WeekInfo(),
              transitionsBuilder: ScreenTransition.fadeTransition,
            ));
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.location_searching),
        ),
      ),
    );
  }

  void _showTopErrorSnackBar() {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.error(
        message: "Ошибка перехода к политике конфиденциальности",
        icon: Icon(Icons.error_outline, size: 0),
      ),
    );
  }
}
