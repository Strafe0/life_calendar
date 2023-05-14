import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:life_calendar/theme.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/utils.dart';
import 'package:intro_slider/intro_slider.dart';

class DatePickerScreen extends StatefulWidget {
  const DatePickerScreen({Key? key}) : super(key: key);

  @override
  State<DatePickerScreen> createState() => _DatePickerScreenState();
}

class _DatePickerScreenState extends State<DatePickerScreen> {
  final CalendarController controller = getIt<CalendarController>();
  DateTime? birthday;
  TextEditingController dateController = TextEditingController();
  List<ContentConfig> listContentConfig = [];
  var screenWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  var screenHeight = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  final _formKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();

    listContentConfig.add(ContentConfig(
      title: "Календарь жизни в неделях",
      styleTitle: introTitleStyle,
      maxLineTitle: 2,
      description: "Иногда жизнь кажется очень короткой, иногда невероятно длинной. Этот календарь дает наглядное представление о количестве прожитых и оставшихся неделей нашей жизни.",
      styleDescription: introDescriptionStyle,
      pathImage: "assets/life_calendar_paper.png",
      widthImage: screenWidth * 0.75,
      heightImage: 950 / 699 * (screenWidth * 0.75),
      foregroundImageFit: BoxFit.contain,
      backgroundColor: const Color(0xFF61D4FF),
    ));

    listContentConfig.add(ContentConfig(
      marginTitle: EdgeInsets.zero,
      description: "Каждая строка календаря соответствует прожитому году (52 или 53 недели). Каждый год начинается с недели, которая содержит ваш день рождения.",
      styleDescription: introDescriptionStyle,
      marginDescription: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0),
      pathImage: "assets/full_calendar_screenshot.png",
      widthImage: screenWidth * 0.75,
      heightImage: screenHeight * 0.7,
      // heightImage: 2052 / 1078 * (screenWidth * 0.75),
      foregroundImageFit: BoxFit.contain,
      backgroundColor: const Color(0xFF61D4FF),
    ));

    listContentConfig.add(ContentConfig(
      marginTitle: EdgeInsets.zero,
      description: "Вы можете увеличивать календарь, как карту. Нажав на квадрат, вы перейдете на экран выбранной недели.",
      styleDescription: introDescriptionStyle,
      marginDescription: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0),
      pathImage: "assets/zoom.png",
      widthImage: screenWidth * 0.75,
      heightImage: screenHeight * 0.7,
      foregroundImageFit: BoxFit.contain,
      backgroundColor: const Color(0xFF61D4FF),
    ));

    listContentConfig.add(ContentConfig(
      marginTitle: EdgeInsets.zero,
      description: "Чтобы сразу перейти к текущей неделе, нажмите на кнопку снизу справа.",
      styleDescription: introDescriptionStyle,
      marginDescription: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0),
      pathImage: "assets/full_calendar_screenshot.png",
      widthImage: screenWidth * 0.75,
      heightImage: screenHeight * 0.7,
      foregroundImageFit: BoxFit.contain,
      backgroundColor: const Color(0xFF61D4FF),
    ));

    listContentConfig.add(ContentConfig(
      title: "Введите дату рождения",
      marginTitle: EdgeInsets.only(top: 32.0, bottom: screenHeight * 0.35),
      styleTitle: introTitleStyle,
      centerWidget: _createDateTextField(),
      backgroundColor: const Color(0xFF61D4FF),
    ));
  }

  void onDonePress() async {
    if (birthday != null) {
      debugPrint('Go to calendar!');
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      key: UniqueKey(),
      listContentConfig: listContentConfig,
      onDonePress: onDonePress,
      renderSkipBtn: Text('Пропустить', style: Theme.of(context).textTheme.labelSmall,),
      renderNextBtn: Text('Дальше', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
      renderDoneBtn: Text('Готово'),
    );
  }

  Widget _createDateTextField() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: TextFormField(
        key: _formKey,
        controller: dateController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.datetime,
        // readOnly: true,
        autofocus: true,
        // focusNode: FocusNode(),
        inputFormatters: [dateMaskFormatter],
        validator: (String? dateTime) {
          if (dateTime != null && dateTime.isNotEmpty) {
            DateTime? convertedDateTime = convertStringToDateTime(dateTime);
            if (convertedDateTime != null) {

              return null;
            }
          }
          return 'Некорректная дата';
        },
        onFieldSubmitted: (String? dateTime) async {
          if (_formKey.currentState!.validate()) {
            DateTime formattedDate = convertStringToDateTime(dateTime!)!;
            debugPrint('formattedDate: $formattedDate');
            birthday = await controller.setBirthday(formattedDate);
          }
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            onPressed: () async {
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
                String formattedDate = formatDate(pickedDate);
                debugPrint('formattedDate: $formattedDate');
                dateController.text = formattedDate;
                birthday = await controller.setBirthday(pickedDate);
              }
            },
            icon: const Icon(Icons.calendar_month),
          ),
        ),
      ),
    );
  }
}

final dateMaskFormatter = MaskTextInputFormatter(
  // mask: 'd#.m#.y# h#:M#',
  mask: '##.##.####',
  filter: {
    "#": RegExp(r'[0-9]'),
    // "d": RegExp(r'[0-3]'),
    // "m": RegExp(r'[01]'),
    // "y": RegExp(r'[0-5]'),
    // "_": RegExp(r'\s'),
    // "2": RegExp(r'2'),
    // "0": RegExp(r'0'),
  },
  type: MaskAutoCompletionType.lazy,
);