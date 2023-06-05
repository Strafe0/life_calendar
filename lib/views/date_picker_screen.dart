import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  var screenWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  var screenHeight = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  double height = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;
  final _formKey = GlobalKey<FormFieldState>();
  final Color colorBegin = const Color(0xFF61D4FF);
  final Color colorEnd = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: IntroSlider(
        key: UniqueKey(),
        listContentConfig: _createListContentConfig(),
        onDonePress: onDonePress,
        renderSkipBtn: Text('Пропустить', style: Theme.of(context).textTheme.labelSmall),
        renderNextBtn: Text('Дальше', style: Theme.of(context).textTheme.bodyLarge),
        renderDoneBtn: Text('Готово', style: Theme.of(context).textTheme.bodyLarge),
        indicatorConfig: IndicatorConfig(
          colorActiveIndicator: Theme.of(context).colorScheme.primary,
          colorIndicator: Theme.of(context).colorScheme.outline,
        ),
      ),
      onWillPop: () async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Выход'),
            content: const Text('Выйти из приложения?'),
            actions: [
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                },
                child: const Text('Да'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Нет'),
              ),
            ],
          ),
        ) ?? false;
      },
    );
  }

  List<ContentConfig> _createListContentConfig() {
    List<ContentConfig> listContentConfig = [];

    listContentConfig.add(ContentConfig(
      title: "Календарь жизни в неделях",
      marginTitle: height < 2000 ? const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24) : null,
      styleTitle: Theme.of(context).textTheme.headlineMedium,
      maxLineTitle: 2,
      description: "Этот календарь дает наглядное представление о количестве прожитых и оставшихся неделей нашей жизни.",
      styleDescription: Theme.of(context).textTheme.bodyMedium,
      marginDescription: height < 2000 ? const EdgeInsets.symmetric(horizontal: 24) : null,
      pathImage: "assets/life_calendar_paper.png",
      widthImage: screenWidth * 0.75,
      heightImage: 950 / 699 * (screenWidth * 0.75),
      foregroundImageFit: BoxFit.contain,
      colorBegin: Theme.of(context).colorScheme.tertiaryContainer,
      colorEnd: Theme.of(context).colorScheme.surface,
    ));

    listContentConfig.add(ContentConfig(
      marginTitle: EdgeInsets.zero,
      description: "Каждая строка календаря соответствует одному году (52 или 53 недели). Каждый год начинается с недели, которая содержит ваш день рождения.",
      styleDescription: Theme.of(context).textTheme.bodyMedium,
      marginDescription: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0),
      pathImage: "assets/full_calendar_screenshot.png",
      widthImage: screenWidth * 0.7,
      heightImage: screenHeight * 0.65,
      // heightImage: 2052 / 1078 * (screenWidth * 0.75),
      foregroundImageFit: BoxFit.contain,
      colorBegin: Theme.of(context).colorScheme.tertiaryContainer,
      colorEnd: Theme.of(context).colorScheme.surface,
    ));

    listContentConfig.add(ContentConfig(
      marginTitle: EdgeInsets.zero,
      description: "Вы можете увеличивать календарь, как карту. Нажав на квадрат, вы перейдете на экран выбранной недели.",
      styleDescription: Theme.of(context).textTheme.bodyMedium,
      marginDescription: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0),
      pathImage: "assets/zoom.png",
      widthImage: screenWidth * 0.75,
      heightImage: screenHeight * 0.7,
      foregroundImageFit: BoxFit.contain,
      colorBegin: Theme.of(context).colorScheme.tertiaryContainer,
      colorEnd: Theme.of(context).colorScheme.surface,
    ));

    listContentConfig.add(ContentConfig(
      marginTitle: EdgeInsets.zero,
      description: "Чтобы сразу перейти к текущей неделе, нажмите на кнопку снизу справа.",
      styleDescription: Theme.of(context).textTheme.bodyMedium,
      marginDescription: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0),
      pathImage: "assets/full_calendar_screenshot.png",
      widthImage: screenWidth * 0.75,
      heightImage: screenHeight * 0.7,
      foregroundImageFit: BoxFit.contain,
      colorBegin: Theme.of(context).colorScheme.tertiaryContainer,
      colorEnd: Theme.of(context).colorScheme.surface,
    ));

    listContentConfig.add(ContentConfig(
      title: "Введите дату рождения",
      marginTitle: EdgeInsets.only(top: screenHeight * 0.3, bottom: screenHeight * 0.1),
      styleTitle: Theme.of(context).textTheme.headlineMedium,
      widgetDescription: _createDateTextField(),
      // centerWidget: _createDateTextField(),
      colorBegin: Theme.of(context).colorScheme.tertiaryContainer,
      colorEnd: Theme.of(context).colorScheme.surface,
    ));

    return listContentConfig;
  }

  void onDonePress() async {
    if (birthday != null) {
      debugPrint('Go to calendar!');
      Navigator.pushReplacementNamed(context, '/');
    }
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