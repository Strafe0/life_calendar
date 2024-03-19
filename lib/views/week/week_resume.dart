import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';

class WeekResume extends StatefulWidget {
  const WeekResume({
    super.key,
    required this.week,
    required this.addResume,
    required this.deleteResume,
  });

  final Week week;
  final Future<void> Function() addResume;
  final Future<void> Function() deleteResume;

  @override
  State<WeekResume> createState() => _WeekResumeState();
}

class _WeekResumeState extends State<WeekResume> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
          child: Align(alignment: Alignment.centerLeft, child: Text('Итог', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.start,)),
        ),
        widget.week.resume.isEmpty ? const Center(child: Text('Не задано')) :
        Card(
          shape: const RoundedRectangleBorder(
            // side: BorderSide(color: Colors.yellow, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 16.0, right: 0),
            child: Row(
              children: [
                Expanded(child: Text(widget.week.resume, style: Theme.of(context).textTheme.bodyMedium,)),
                PopupMenuButton<int>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  onSelected: (value) async {
                    if (value == 1) {
                      await widget.addResume();
                      setState(() {});
                    } else if (value == 2) {
                      await widget.deleteResume();
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
}
