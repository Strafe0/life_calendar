import 'package:flutter/material.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/theme.dart';
import 'package:life_calendar/utils/utility_functions.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:life_calendar/utils/utility_variables.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class WeekInfo extends StatefulWidget {
  const WeekInfo({super.key});

  @override
  State<WeekInfo> createState() => _WeekInfoState();
}

class _WeekInfoState extends State<WeekInfo> {
  final CalendarController controller = getIt<CalendarController>();
  WeekAssessment? assessment;
  final TextEditingController _textController = TextEditingController();
  bool _validate = true;
  final TextEditingController _dateController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    assessment = controller.selectedWeek.assessment;
  }

  BannerAdSize get adSize {
    final screenWidth = MediaQuery.of(context).size.width.round();
    return BannerAdSize.sticky(width: screenWidth);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build WeekInfo');

    Week week = controller.selectedWeek;

    final banner = BannerAd(
      // adUnitId: 'demo-banner-yandex',
      adUnitId: 'R-M-2265467-1',
      adSize: adSize,
      adRequest: const AdRequest(),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Неделя ${formatDate(week.start)} - ${formatDate(week.end)}'),
        titleSpacing: 0,
        leadingWidth: 48,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 70),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                const SizedBox(height: 20.0,),
                assessmentWidget(),
                const SizedBox(height: 20.0,),
                goalsWidget(),
                const SizedBox(height: 20.0,),
                eventsWidget(),
                const SizedBox(height: 20.0,),
                resumeWidget(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AdWidget(bannerAd: banner),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        spaceBetweenChildren: 16,
        children: [
          SpeedDialChild(
            labelWidget: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text('Итог'),
            ),
            child: const Icon(Icons.edit),
            onTap: _showResumeDialog,
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
          SpeedDialChild(
            labelWidget: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text('Событие'),
            ),
            child: const Icon(Icons.calendar_today),
            onTap: addEvent,
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
          SpeedDialChild(
            labelWidget: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text('Цель'),
            ),
            child: const Icon(Icons.check),
            onTap: addGoal,
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
        ],
      ),
    );
  }

  Future<void> addEvent() async {
    if (controller.selectedWeek.events.length >= 3) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Достигнут предел событий на неделю",
          icon: Icon(Icons.error_outline, size: 0),
        ),
      );
      return;
    }

    _textController.clear();

    _validate = true;
    Event? newEvent = await _showEventDialog(controller.selectedWeek.start, isCreation: true);
    if (newEvent != null) {
      setState(() {
        controller.addEvent(newEvent);
      });
    }
  }

  Future<void> addGoal() async {
    if (controller.selectedWeek.goals.length >= 3) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Достигнут предел целей на неделю",
          icon: Icon(Icons.error_outline, size: 0),
        ),
      );
      return;
    }

    _textController.clear();

    _validate = true;
    String? goalTitle = await _showGoalTitleDialog(isCreation: true);
    if (goalTitle != null && goalTitle.isNotEmpty) {
      controller.addGoal(goalTitle).then((value) => setState(() {}));
    }
  }

  Widget assessmentWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
          child: Text('Дайте оценку неделе', style: Theme.of(context).textTheme.titleMedium,),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                radioButton(WeekAssessment.good, goodWeekColor),
                radioButton(WeekAssessment.bad, badWeekColor),
                radioButton(WeekAssessment.poor, Theme.of(context).colorScheme.secondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget radioButton(WeekAssessment value, Color color) {
    return Column(
      children: [
        Radio(
          value: value,
          groupValue: assessment,
          fillColor: MaterialStatePropertyAll(color),
          onChanged: (WeekAssessment? newValue) {
            if (newValue != null) {
              setState(() {
                assessment = newValue;
                controller.changeAssessment(newValue);
              });
            }
          },
        ),
        Text(value.name, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget goalsWidget() {
    Week week = controller.selectedWeek;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
          child: Text('Цели', style: Theme.of(context).textTheme.titleMedium),
        ),
        week.goals.isEmpty ? const Center(child: Text('Нет задач')) :
        ListView.builder(
          itemCount: week.goals.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (week.goals.isEmpty) {
              return const Center(child: Text('Нет поставленных задач'));
            }

            return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: CheckboxListTile(
                value: week.goals[index].isCompleted,
                title: Text(week.goals[index].title, style: Theme.of(context).textTheme.bodyMedium,),
                contentPadding: const EdgeInsets.only(left: 8),
                onChanged: (bool? newValue) {
                  if (newValue != null) {
                    setState(() {
                      controller.changeGoalCompletion(index, newValue);
                    });
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                secondary: PopupMenuButton<int>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text('Изменить', style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('Удалить', style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 1) {
                      await _changeGoalTitle(index);
                      setState(() {});
                    } else if (value == 2) {
                      await controller.deleteGoal(index);
                      setState(() {});
                    }
                  },
                ),
              ),
            );
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
        ),
      ],
    );
  }

  Future _changeGoalTitle(int index) async {
    _textController.text = controller.selectedWeek.goals[index].title;
    _validate = true;

    String? updatedGoalTitle = await _showGoalTitleDialog(isCreation: false);
    if (updatedGoalTitle != null && updatedGoalTitle.isNotEmpty) {
      setState(() {
        controller.changeGoalTitle(index, updatedGoalTitle);
      });
    }
  }

  Future<String?> _showGoalTitleDialog({required bool isCreation}) async {
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isCreation ? 'Создание цели' : 'Изменение цели'),
              content: TextField(
                controller: _textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Введите название',
                  errorText: _validate ? null : 'Поле не может быть пустым',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _validate = _textController.text.isNotEmpty;
                    });
                    if (_validate) {
                      Navigator.pop(context, _textController.text);
                    }
                  },
                  child: const Text('Ок'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget eventsWidget() {
    Week week = controller.selectedWeek;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
          child: Text('События', style: Theme.of(context).textTheme.titleMedium),
        ),
        week.events.isEmpty ? const Center(child: Text('Нет событий')) :
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: week.events.length,
          itemBuilder: (context, index) {
            Event event = week.events[index];

            return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: ListTile(
                title: Text(event.title, style: Theme.of(context).textTheme.bodyMedium,),
                subtitle: Text(formatDate(event.date), style: Theme.of(context).textTheme.bodySmall,),
                contentPadding: const EdgeInsets.only(left: 16),
                trailing: PopupMenuButton<int>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  onSelected: (value) async {
                    if (value == 1) {
                      await changeEvent(index, event);
                      setState(() {});
                    } else if (value == 2) {
                      await controller.deleteEvent(index);
                      setState(() {});
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text('Изменить', style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('Удалить', style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ],
                ),
              ),
            );
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
        ),
      ],
    );
  }

  Future changeEvent(int index, Event event) async {
    _textController.text = event.title;
    _validate = true;

    Event? updatedEvent = await _showEventDialog(event.date, isCreation: false);
    if (updatedEvent != null) {
      setState(() {
        controller.changeEvent(index, updatedEvent);
      });
    }
  }

  Future<Event?> _showEventDialog(DateTime initialDate, {required bool isCreation}) async {
    Week week = controller.selectedWeek;
    DateTime eventDate = initialDate;
    _dateController.text = formatDate(initialDate);
    final eventForm = GlobalKey<FormState>();

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCreation ? 'Создание события' : 'Изменение события'),
          content: StatefulBuilder(
            builder: (context, setState) => Form(
              key: eventForm,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _textController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Введите название',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Поле не может быть пустым';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [dateMaskFormatter],
                    decoration: InputDecoration(
                      hintText: 'ДД.ММ.ГГГГ',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          DateTime? pickedDateTime = await selectDateTimeInCalendar(context, initialDate: initialDate);
                          if (pickedDateTime != null) {
                            _dateController.text = formatDate(pickedDateTime);
                            eventDate = pickedDateTime;
                          }
                        },
                      ),
                    ),
                    validator: (String? dateTime) {
                      if (dateTime != null && dateTime.isNotEmpty) {
                        DateTime? convertedDateTime = convertStringToDateTime(dateTime, firstDate: week.start, lastDate: week.end);
                        if (convertedDateTime == null) {
                          return 'Дата не соответствует неделе';
                        }
                        return null;
                      } else {
                        return 'Введите дату и время';
                      }
                    },
                    onFieldSubmitted: (String? date) {
                      if (date != null) {
                        DateTime? converted = convertStringToDateTime(date, firstDate: week.start, lastDate: week.end);
                        if (converted != null) {
                          eventDate = converted;
                        }
                      }
                    },
                    onSaved: (String? date) {
                      if (date != null) {
                        DateTime? converted = convertStringToDateTime(date, firstDate: week.start, lastDate: week.end);
                        if (converted != null) {
                          eventDate = converted;
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                _validate = eventForm.currentState!.validate();
                if (_validate) {
                  eventForm.currentState!.save();
                  Navigator.pop(context, Event(_textController.text, eventDate));
                }
              },
              child: const Text('Ок'),
            ),
          ],
        );
      },
    );
  }

  Widget resumeWidget() {
    String resume = controller.selectedWeek.resume;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
          child: Align(alignment: Alignment.centerLeft, child: Text('Итог', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.start,)),
        ),
        resume.isEmpty ? const Center(child: Text('Не задано')) :
        Card(
          shape: const RoundedRectangleBorder(
            // side: BorderSide(color: Colors.yellow, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 16.0, right: 0),
            child: Row(
              children: [
                Expanded(child: Text(resume, style: Theme.of(context).textTheme.bodyMedium,)),
                PopupMenuButton<int>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  onSelected: (value) async {
                    if (value == 1) {
                      await _showResumeDialog();
                      setState(() {});
                    } else if (value == 2) {
                      await controller.deleteResume();
                      setState(() {});
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text('Изменить', style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('Удалить', style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future _showResumeDialog() async {
    _textController.text = controller.selectedWeek.resume;

    String? resumeText = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Запишите ваши мысли о неделе'),
              content: TextField(
                controller: _textController,
                autofocus: true,
                maxLength: 500,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Введите итоги недели',
                  errorText: _validate ? null : 'Поле не может быть пустым',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _validate = _textController.text.isNotEmpty;
                    });
                    if (_validate) {
                      Navigator.pop(context, _textController.text);
                    }
                  },
                  child: const Text('Ок'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resumeText != null && resumeText.isNotEmpty) {
      setState(() {
        controller.addResume(resumeText);
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
