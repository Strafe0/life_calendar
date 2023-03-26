import 'package:flutter/material.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/theme.dart';
import 'package:life_calendar/utils.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
    Week week = controller.selectedWeek;
    Size screenSize = MediaQuery.of(context).size;

    final banner = BannerAd(
      adUnitId: 'R-M-2265467-1',
      // Flex-size
      // adSize: AdSize.flexible(width: screenSize.width, height: bannerHeight),
      // Sticky-size
      adSize: AdSize.sticky(width: screenSize.width.toInt()),
      adRequest: AdRequest(),
      onAdLoaded: () {
        /* Do something */
      },
      onAdFailedToLoad: (error) {
        /* Do something */
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Неделя ${formatDate(week.start)} - ${formatDate(week.end)}'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                assessmentWidget(),
                const SizedBox(height: 8.0,),
                goalsWidget(),
                const SizedBox(height: 8.0,),
                eventsWidget(),
                const SizedBox(height: 8.0,),
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
        children: [
          SpeedDialChild(
            child: const Icon(Icons.calendar_today),
            onTap: addEvent,
          ),
          SpeedDialChild(
            child: const Icon(Icons.check_circle),
            onTap: addGoal,
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit),
            onTap: addResume,
          ),
        ],
      ),
    );
  }

  Future<void> addEvent() async {
    _textController.clear();

    _validate = true;
    Event? newEvent = await _showEventDialog();
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
      setState(() {
        controller.addGoal(goalTitle);
      });
    }
  }

  Widget assessmentWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text('Дайте оценку неделе', style: Theme.of(context).textTheme.titleMedium,),
        ),
        Card(
          color: Colors.blue[100],
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                radioButton(WeekAssessment.good, goodWeekColor),
                radioButton(WeekAssessment.bad, badWeekColor),
                radioButton(WeekAssessment.poor, poorWeekColor),
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
        Text(value.name),
      ],
    );
  }

  Widget goalsWidget() {
    Week week = controller.selectedWeek;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text('Цели', style: Theme.of(context).textTheme.titleMedium),
        ),
        week.goals.isEmpty ? const Center(child: Text('Нет задач')) :
        ListView.builder(
          itemCount: week.goals.length,
          itemBuilder: (context, index) {
            if (week.goals.isEmpty) {
              return const Center(child: Text('Нет поставленных задач'));
            }

            return Card(
              elevation: 8.0,
              color: Colors.purple[50],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: CheckboxListTile(
                value: week.goals[index].isCompleted,
                title: Text(week.goals[index].title),
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
          padding: const EdgeInsets.only(left: 12.0),
          child: Text('События', style: Theme.of(context).textTheme.titleMedium),
        ),
        week.events.isEmpty ? const Center(child: Text('Нет событий')) :
        ListView.builder(
          itemCount: week.events.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4.0,
              color: Colors.orangeAccent[100],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: ListTile(
                title: Text(week.events[index].title),
                subtitle: Text(formatDate(week.events[index].date)),
                trailing: PopupMenuButton<int>(
                  onSelected: (value) async {
                    if (value == 1) {
                      await changeEvent(index);
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

  Future changeEvent(int index) async {
    _textController.text = controller.selectedWeek.events[index].title;
    _validate = true;

    String? newEventTitle = await _showGoalTitleDialog();
    if (newEventTitle != null && newEventTitle.isNotEmpty) {
      setState(() {
        controller.changeEventTitle(index, newEventTitle);
      });
    }
  }

  Future<Event?> _showEventDialog() async {
    Week week = controller.selectedWeek;
    DateTime eventDate = week.start;
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
                  InputDatePickerFormField(
                    initialDate: week.start,
                    firstDate: week.start,
                    lastDate: week.end,
                    errorFormatText: 'Неверный формат даты',
                    errorInvalidText: 'Дата не соответствует неделе',
                    onDateSubmitted: (date) {
                      setState(() {
                        eventDate = date;
                      });
                    },
                    onDateSaved: (date) {
                      setState(() {
                        eventDate = date;
                      });
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
                setState(() {
                  _validate = eventForm.currentState?.validate() ?? false;
                });
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
          padding: const EdgeInsets.only(left: 12.0),
          child: Align(alignment: Alignment.centerLeft, child: Text('Итог', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.start,)),
        ),
        resume.isEmpty ? const Center(child: Text('Не задано')) :
        Card(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.yellow, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(resume),
          ),
        ),
      ],
    );
  }

  Future addResume() async {
    _textController.clear();

    _validate = true;
    String? resumeText = await _showResumeDialog();
    if (resumeText != null && resumeText.isNotEmpty) {
      setState(() {
        controller.addResume(resumeText);
      });
    }
  }

  Future<String?> _showResumeDialog() async {
    return await showDialog<String>(
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
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
