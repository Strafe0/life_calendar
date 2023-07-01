import 'package:flutter/material.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/theme.dart';
import 'package:life_calendar/utils/utility_functions.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:life_calendar/utils/utility_variables.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

class WeekInfo extends StatefulWidget {
  const WeekInfo({Key? key}) : super(key: key);

  @override
  State<WeekInfo> createState() => _WeekInfoState();
}

class _WeekInfoState extends State<WeekInfo> {
  final CalendarController controller = getIt<CalendarController>();
  WeekAssessment? assessment;
  late TextEditingController _textController;
  bool _validate = true;
  
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    assessment = controller.selectedWeek.assessment;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build WeekInfo');

    Week week = controller.selectedWeek;
    Size screenSize = MediaQuery.of(context).size;

    final banner = BannerAd(
      // adUnitId: 'demo-banner-yandex',
      adUnitId: 'R-M-2265467-1',
      // Flex-size
      // adSize: AdSize.flexible(width: screenSize.width, height: bannerHeight),
      // Sticky-size
      adSize: AdSize.sticky(width: screenSize.width.toInt()),
      adRequest: const AdRequest(),
      onAdLoaded: () {
        /* Do something */
      },
      onAdFailedToLoad: (error) {
        /* Do something */
      },
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
            label: 'Заметка',
            labelBackgroundColor: Colors.transparent,
            child: const Icon(Icons.edit),
            onTap: _showResumeDialog,
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
          SpeedDialChild(
            label: 'Событие',
            labelBackgroundColor: Colors.transparent,
            child: const Icon(Icons.calendar_today),
            onTap: addEvent,
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
          SpeedDialChild(
            label: 'Задача',
            labelBackgroundColor: Colors.transparent,
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
    _textController.clear();

    _validate = true;
    Event? newEvent = await _showEventDialog(controller.selectedWeek.start);
    if (newEvent != null) {
      setState(() {
        controller.addEvent(newEvent);
      });
    }
  }

  Future<void> addGoal() async {
    _textController.clear();

    _validate = true;
    String? goalTitle = await _showGoalTitleDialog();
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
                title: Text(week.goals[index].title),
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
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Text('Изменить'),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('Удалить'),
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

    String? newGoalTitle = await _showGoalTitleDialog();
    if (newGoalTitle != null && newGoalTitle.isNotEmpty) {
      setState(() {
        controller.changeGoalTitle(index, newGoalTitle);
      });
    }
  }

  Future<String?> _showGoalTitleDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Введите новое значение'),
              content: TextField(
                controller: _textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Введите название',
                  errorText: _validate ? null : 'Поле не может быть пустым',
                ),
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
                title: Text(event.title),
                subtitle: Text(formatDate(event.date)),
                contentPadding: const EdgeInsets.only(left: 16),
                trailing: PopupMenuButton<int>(
                  onSelected: (value) async {
                    if (value == 1) {
                      await changeEvent(index, event);
                      setState(() {});
                    } else if (value == 2) {
                      await controller.deleteEvent(index);
                      setState(() {});
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 1,
                      child: Text('Изменить'),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('Удалить'),
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

    Event? newEvent = await _showEventDialog(event.date);
    if (newEvent != null) {
      setState(() {
        controller.changeEvent(index, newEvent);
      });
    }
  }

  Future<Event?> _showEventDialog(DateTime initialDate) async {
    Week week = controller.selectedWeek;
    DateTime eventDate = initialDate;
    final eventForm = GlobalKey<FormState>();

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Введите новое значение'),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Поле не может быть пустым';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InputDatePickerFormField(
                    initialDate: initialDate,
                    firstDate: week.start,
                    lastDate: week.end,
                    errorFormatText: 'Неверный формат даты',
                    errorInvalidText: 'Дата не соответствует неделе',
                    onDateSubmitted: (date) {
                      eventDate = date;
                    },
                    onDateSaved: (date) {
                      eventDate = date;
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
                eventForm.currentState!.save();
                _validate = eventForm.currentState!.validate();
                if (_validate) {
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
                Expanded(child: Text(resume)),
                PopupMenuButton<int>(
                  onSelected: (value) async {
                    if (value == 1) {
                      await _showResumeDialog();
                      setState(() {});
                    } else if (value == 2) {
                      await controller.deleteResume();
                      setState(() {});
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 1,
                      child: Text('Изменить'),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('Удалить'),
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

  // Future addResume() async {
  //   _textController.clear();
  //
  //   _validate = true;
  //   String? resumeText = await _showResumeDialog();
  //   if (resumeText != null && resumeText.isNotEmpty) {
  //     setState(() {
  //       controller.addResume(resumeText);
  //     });
  //   }
  // }
  //
  // Future changeResume() async {
  //   _textController.text = controller.selectedWeek.resume;
  //
  //   String? resumeText = await _showResumeDialog();
  // }

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
