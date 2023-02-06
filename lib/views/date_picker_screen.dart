import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/models/calendar_model.dart';
import 'package:life_calendar/views/calendar/calendar_screen.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class DatePickerScreen extends StatefulWidget {
  const DatePickerScreen({Key? key}) : super(key: key);

  @override
  State<DatePickerScreen> createState() => _DatePickerScreenState();
}

class _DatePickerScreenState extends State<DatePickerScreen> {
  DateTime? birthday;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Календарь жизни в неделях'),
        ),
        body: Center(
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Выберите дату вашего рождения'),
                _createDateTextField(),
                _createDateTimeTextField(),
                _createDateInputField(),
              ],
            ),
          ),
        ),
        floatingActionButton: ElevatedButton(
          onPressed: () {
            if (birthday != null) {
              getIt<CalendarModel>().selectedBirthday = birthday!;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CalendarScreen()));
            }
          },
          child: const Text('Продолжить'),
        ),
      ),
    );
  }

  Widget _createDateTextField() {
    TextEditingController dateController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: TextField(
        controller: dateController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.datetime,
        readOnly: true,
        focusNode: FocusNode(),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime(2009),
            initialEntryMode: DatePickerEntryMode.calendar,
            initialDatePickerMode: DatePickerMode.year,
            locale: const Locale('ru'),
          );
          debugPrint('pickedDate: $pickedDate');

          if (pickedDate != null) {
            String formattedDate = DateFormat('dd.MM.yyyy').format(pickedDate);
            debugPrint('formattedDate: $formattedDate');
            dateController.text = formattedDate;
            birthday = pickedDate;
          }
        },
      ),
    );
  }
  
  Widget _createDateTimeTextField() {
    TextEditingController dateTimeController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: dateTimeController,
        textAlign: TextAlign.center,
        readOnly: true,
        focusNode: FocusNode(),
        onTap: () async {
          DateTime? pickedDateTime = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2050),
            initialEntryMode: DatePickerEntryMode.calendar,
            initialDatePickerMode: DatePickerMode.year,
            locale: const Locale('ru'),
          ).then((date) async {
            TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              ),
            );

            debugPrint('pickedTime: $time');
            if (date != null && time != null) {
              return DateTime(date.year, date.month, date.day, time.hour, time.minute);
            } else {
              return null;
            }
          });
          debugPrint('pickedDate: $pickedDateTime');

          if (pickedDateTime != null) {
            String formattedDate = DateFormat('dd.MM.yyyy, HH:mm').format(pickedDateTime);
            debugPrint('formattedDate: $formattedDate');
            dateTimeController.text = formattedDate;
          }
        },
        onChanged: (dateTime) {
          DateTime? pickedDateTime = DateTime.tryParse(dateTime);
          debugPrint('PARSED : $pickedDateTime');
        },
        onSubmitted: null,
      ),
    );
  }

  Widget _createDateInputField() {
    TextEditingController dateTimeController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 16),
      child: TextFormField(
        controller: dateTimeController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.number,
        inputFormatters: [dateMaskFormatter],
        // validator: (String? dateTime) {
        //   if (dateTime == null || dateTime.isEmpty) {
        //     return 'Введите дату и время';
        //   } else {
        //     DateTime? convertedDateTime = convertStringToDateTime(dateTime);
        //     if (convertedDateTime == null) {
        //       return 'Недопустимое значение';
        //     }
        //     return null;
        //   }
        // },
        // onChanged: (String? newDateTime) {
        //   if (newDateTime != null) {
        //     initialDateTime = convertStringToDateTime(newDateTime);
        //     if (initialDateTime != null) {
        //       int unixTime = Duration(
        //           milliseconds: initialDateTime!.toUtc().millisecondsSinceEpoch
        //       ).inSeconds;
        //       propertyProvider.setValue(unixTime);
        //     }
        //   }
        // },
      ),
    );
  }
}

final dateMaskFormatter = MaskTextInputFormatter(
  mask: 'd#.m#.y# h#:M#',
  filter: {
    "#": RegExp(r'[0-9]'),
    "d": RegExp(r'[0-3]'),
    "m": RegExp(r'[01]'),
    "y": RegExp(r'[0-5]'),
    // "_": RegExp(r'\s'),
    // "2": RegExp(r'2'),
    // "0": RegExp(r'0'),
    "h": RegExp(r'[012]'),
    "M": RegExp(r'[0-5]'),
  },
  type: MaskAutoCompletionType.eager,
);