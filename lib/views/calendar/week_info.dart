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
          eventsWidget(),
        ],
      ),
      floatingActionButton: SpeedDial(
        children: [ //todo: do all actions in dialog
          SpeedDialChild(
            child: const Icon(Icons.calendar_today),
            onTap: addEventCallback,
          ),
          SpeedDialChild(
            child: const Icon(Icons.check_circle),
            onTap: () {
              //todo: add task
            }
          ),
          // SpeedDialChild(
          //   child: const Icon(Icons.palette),
          //   onTap: () {
          //     //todo: change color
          //   }
          // ),
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
    String? eventTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Введите название события'),
              content: TextField(
                controller: _textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Введите название события',
                  errorText: _validate ? null : 'Введите значение',
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
    if (eventTitle != null && eventTitle.isNotEmpty) {
      setState(() {
        controller.addEvent(eventTitle);
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
              if (week.events.isEmpty) {
                return const Center(child: Text('Нет событий'));
              }

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

    String? newEventTitle = await showDialog<String>(
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
                  hintText: 'Введите название события',
                  errorText: _validate ? null : 'Введите значение',
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
    if (newEventTitle != null && newEventTitle.isNotEmpty) {
      setState(() {
        controller.changeEvent(newEventTitle, index);
      });
    }
  }

  Widget goalsWidget() {
    Week week = controller.selectedWeek;
    TextEditingController textController = TextEditingController();

    return Card(
      child: Column(
        children: [
          const Text('Цели'),
          ListView.builder(
            itemCount: week.goals.length,
            itemBuilder: (context, index) {
              if (week.goals.isEmpty) {
                return const Center(child: Text('Нет поставленных задач'));
              }

              return CheckboxListTile(
                value: false,
                title: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
                onChanged: null,
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
                  onSelected: (value) {
                    if (value == 1) {
                      //todo: focus on text field
                      
                    } else if (value == 2) {
                      //todo: remove goal
                      setState(() {
                        week.goals.removeAt(index);
                      });
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
