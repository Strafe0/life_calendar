import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';

class DatePickerScreen extends StatefulWidget {
  const DatePickerScreen({Key? key}) : super(key: key);

  @override
  State<DatePickerScreen> createState() => _DatePickerScreenState();
}

class _DatePickerScreenState extends State<DatePickerScreen> {
  final CalendarController controller = getIt<CalendarController>();
  DateTime? birthday;
  TextEditingController dateController = TextEditingController();

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
                // _createDateTimeTextField(),
                // _createDateInputField(),
              ],
            ),
          ),
        ),
        floatingActionButton: ElevatedButton(
          onPressed: birthday == null ? null : () {
            Navigator.pushReplacementNamed(context, '/');
          },
          child: const Text('Продолжить'),
        ),
      ),
    );
  }

  Widget _createDateTextField() {
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
            birthday = await controller.setBirthday(pickedDate);
            setState(() {});
          }
        },
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