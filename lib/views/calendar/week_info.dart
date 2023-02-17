import 'package:flutter/material.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/utils.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class WeekInfo extends StatefulWidget {
  const WeekInfo({Key? key}) : super(key: key);

  @override
  State<WeekInfo> createState() => _WeekInfoState();
}

class _WeekInfoState extends State<WeekInfo> {
  final CalendarController controller = getIt<CalendarController>();
  WeekAssessment? assessment = WeekAssessment.poor;
  late TextEditingController _textController;
  bool _validate = true;
  
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    Week week = controller.selectedWeek;

    return Scaffold(
      appBar: AppBar(
        title: Text('Неделя ${formatDate(week.start)} - ${formatDate(week.end)}'),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          assessmentWidget(),
          goalsWidget(),
          eventsWidget(),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        children: [ //todo: do all actions in dialog
          SpeedDialChild(
            child: const Icon(Icons.calendar_today),
            onTap: addEventCallback,
          ),
          SpeedDialChild(
            child: const Icon(Icons.check_circle),
            onTap: addGoal,
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit),
            onTap: () {
              //todo: add note
            }
          ),
        ],
      ),
    );
  }

  Future<void> addEventCallback() async {
    _textController.clear();

    _validate = true;
    String? eventTitle = await _showChangeTitleDialog();
    if (eventTitle != null && eventTitle.isNotEmpty) {
      setState(() {
        controller.addEvent(eventTitle);
      });
    }
  }

  Future<void> addGoal() async {
    _textController.clear();

    _validate = true;
    String? goalTitle = await _showChangeTitleDialog();
    if (goalTitle != null && goalTitle.isNotEmpty) {
      setState(() {
        controller.addGoal(goalTitle);
      });
    }
  }

  Widget assessmentWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.blue[100],
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text('Дайте оценку неделе'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  radioButton(WeekAssessment.good),
                  radioButton(WeekAssessment.bad),
                  radioButton(WeekAssessment.poor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget radioButton(WeekAssessment value) {
    return Column(
      children: [
        Radio(
          value: value,
          groupValue: assessment,
          onChanged: (WeekAssessment? newValue) {
            setState(() {
              assessment = newValue;
            });
          },
        ),
        Text(value.name),
      ],
    );
  }

  Widget eventsWidget() {
    Week week = controller.selectedWeek;

    return Card(
      child: Column(
        children: [
          const Text('События'),
          week.events.isEmpty ? const Center(child: Text('Нет событий')) :
          ListView.builder(
            itemCount: week.events.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(week.events[index]),
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
              );
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }

  Future changeEvent(int index) async {
    _textController.text = controller.selectedWeek.events[index];
    _validate = true;

    String? newEventTitle = await _showChangeTitleDialog();
    if (newEventTitle != null && newEventTitle.isNotEmpty) {
      setState(() {
        controller.changeEvent(index, newEventTitle);
      });
    }
  }

  Widget goalsWidget() {
    Week week = controller.selectedWeek;

    return Card(
      child: Column(
        children: [
          const Text('Цели'),
          week.goals.isEmpty ? const Center(child: Text('Нет задач')) :
          ListView.builder(
            itemCount: week.goals.length,
            itemBuilder: (context, index) {
              if (week.goals.isEmpty) {
                return const Center(child: Text('Нет поставленных задач'));
              }

              return CheckboxListTile(
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
              );
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }

  Future _changeGoalTitle(int index) async {
    _textController.text = controller.selectedWeek.goals[index].title;
    _validate = true;

    String? newGoalTitle = await _showChangeTitleDialog();
    if (newGoalTitle != null && newGoalTitle.isNotEmpty) {
      setState(() {
        controller.changeGoalTitle(index, newGoalTitle);
      });
    }
  }

  Future<String?> _showChangeTitleDialog() async {
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
