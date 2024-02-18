import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/utils/text_dialog.dart';

class WeekGoals extends StatefulWidget {
  const WeekGoals(
      {super.key,
      required this.selectedWeek,
      required this.changeGoalCompletion,
      required this.changeGoalTitle,
      required this.deleteGoal});

  final Week selectedWeek;
  final void Function(int, bool) changeGoalCompletion;
  final void Function(int, String) changeGoalTitle;
  final Future<void> Function(int) deleteGoal;

  @override
  State<WeekGoals> createState() => _WeekGoalsState();
}

class _WeekGoalsState extends State<WeekGoals> {
  Week get week => widget.selectedWeek;

  @override
  Widget build(BuildContext context) {
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
                      widget.changeGoalCompletion(index, newValue);
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
                      await widget.deleteGoal(index);
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
    String? updatedGoalTitle = await textDialog(context,
      title: 'Изменение цели',
      initialText: week.goals[index].title,
    );
    if (updatedGoalTitle != null && updatedGoalTitle.isNotEmpty) {
      setState(() {
        widget.changeGoalTitle(index, updatedGoalTitle);
      });
    }
  }
}