import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/utils/event_dialog.dart';

import 'package:life_calendar/utils/utility_functions.dart';

class WeekEvents extends StatefulWidget {
  const WeekEvents({
    super.key,
    required this.week,
    required this.deleteEvent,
    required this.changeEvent,
  });

  final Week week;
  final Future<void> Function(int index) deleteEvent;
  final Future<void> Function(int index, Event event) changeEvent;

  @override
  State<WeekEvents> createState() => _WeekEventsState();
}

class _WeekEventsState extends State<WeekEvents> {
  Week get week => widget.week;


  @override
  Widget build(BuildContext context) {
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
                      await changeEventFields(index, event);
                      setState(() {});
                    } else if (value == 2) {
                      await widget.deleteEvent(index);
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

  Future changeEventFields(int index, Event event) async {
    Event? updatedEvent = await eventDialog(context,
      title: "Изменение события",
      initialText: event.title,
      initialDate: event.date,
      weekStartDate: week.start,
      weekEndDate: week.end,
    );
    if (updatedEvent != null) {
      setState(() {
        widget.changeEvent(index, updatedEvent);
      });
    }
  }
}
