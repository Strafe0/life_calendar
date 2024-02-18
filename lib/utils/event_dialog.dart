import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/utils/utility_functions.dart';
import 'package:life_calendar/utils/utility_variables.dart';

Future<Event?> eventDialog(BuildContext context, {
  required String title,
  String? initialText,
  required DateTime initialDate,
  required DateTime weekStartDate,
  required DateTime weekEndDate,
}) async {
  final textController = TextEditingController();
  final dateController = TextEditingController();
  bool validate = false;

  DateTime eventDate = initialDate;
  dateController.text = formatDate(initialDate);
  final eventForm = GlobalKey<FormState>();

  if (initialText != null) {
    textController.text = initialText;
  }

  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setState) => Form(
            key: eventForm,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: textController,
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
                  controller: dateController,
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [dateMaskFormatter],
                  decoration: InputDecoration(
                    hintText: 'ДД.ММ.ГГГГ',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () async {
                        DateTime? pickedDateTime = await selectDateTimeInCalendar(context, initialDate: initialDate);
                        if (pickedDateTime != null) {
                          dateController.text = formatDate(pickedDateTime);
                          eventDate = pickedDateTime;
                        }
                      },
                    ),
                  ),
                  validator: (String? dateTime) {
                    if (dateTime != null && dateTime.isNotEmpty) {
                      DateTime? convertedDateTime = convertStringToDateTime(dateTime, firstDate: weekStartDate, lastDate: weekEndDate);
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
                      DateTime? converted = convertStringToDateTime(date, firstDate: weekStartDate, lastDate: weekEndDate);
                      if (converted != null) {
                        eventDate = converted;
                      }
                    }
                  },
                  onSaved: (String? date) {
                    if (date != null) {
                      DateTime? converted = convertStringToDateTime(date, firstDate: weekStartDate, lastDate: weekEndDate);
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
              validate = eventForm.currentState!.validate();
              if (validate) {
                eventForm.currentState!.save();
                Navigator.pop(context, Event(textController.text, eventDate));
              }
            },
            child: const Text('Ок'),
          ),
        ],
      );
    },
  );
}