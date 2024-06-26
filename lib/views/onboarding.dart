import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/utils/utility_variables.dart';
import 'package:life_calendar/utils/utility_functions.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isLightMode = MediaQuery.of(context).platformBrightness == Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isLightMode ? const Color(0xFF356CF9) : const Color(0xFF00174D),
    ));

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }

        await showDialog<bool>(
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
      child: Scaffold(
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(isLightMode ? 0xFF356CF9 : 0xFF00174D),
                  Color(isLightMode ? 0xFF83ABFC : 0xFF00174D),
                  Color(isLightMode ? 0xFFFFFFFF : 0xFF1C1B1F),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          pageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _pages[index];
                      },
                    ),
                  ),
                  bottomBar(),
                  const SizedBox(height: 72),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomBar() {
    double width = MediaQuery.of(context).size.width;

    if (pageIndex == 0) {
      return SizedBox(
        height: 52,
        width: 0.5 * width,
        child: ElevatedButton(
          onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
          child: const Text('СТАРТ'),
        ),
      );
    } else if (pageIndex < _pages.length - 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 4,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Visibility(
                visible: pageIndex != _pages.length - 1,
                child: TextButton(
                  onPressed: () => _pageController.jumpToPage(_pages.length-1),
                  child: Text('Пропустить', style: Theme.of(context).textTheme.labelLarge),
                ),
              ),
            ),
          ),
          // const Spacer(),
          Flexible(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) => DotIndicator(isActive: index == pageIndex)),
            ),
          ),
          // const Spacer(),
          Flexible(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  if (pageIndex < _pages.length - 1) {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  } else if (pageIndex == _pages.length - 1) {

                  }
                },
                child: Text(pageIndex != _pages.length - 1 ? 'Дальше' : 'Готово', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

const List<Widget> _pages = [
  OnBoardingPage(
    image: "assets/onboarding/life_calendar_paper.png",
    title: "Календарь жизни в неделях",
    description: "Этот календарь дает наглядное представление о количестве прожитых и оставшихся неделей нашей жизни.",
  ),
  OnBoardingPage(
    image: "assets/onboarding/onboarding2.png",
    title: "Календарь жизни в неделях",
    description: "Каждая строка календаря соответствует одному году (52 или 53 недели). Каждый год начинается с недели, которая содержит ваш день рождения.",
  ),
  OnBoardingPage(
    image: "assets/onboarding/zoom_select.png",
    title: "Увеличивайте календарь и выбирайте неделю",
    description: "Вы можете приблизить календарь. Нажав на квадрат, вы перейдете на экран выбранной недели.",
  ),
  OnBoardingPage(
    image: "assets/onboarding/onboarding4.png",
    title: "Переходите к текущей неделе одним нажатием",
    description: "Чтобы сразу перейти к текущей неделе, нажмите на кнопку снизу справа.",
  ),
  DateInputScreen(),
];

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key, required this.image, required this.title, required this.description});

  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const Spacer(),
            Image.asset(image, width: 0.8 * width, height: 0.5 * height),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
            const SizedBox(height: 16),
            Text(description, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center,),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: AnimatedContainer(
        height: isActive ? 12 : 9,
        width: isActive ? 12 : 9,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class DateInputScreen extends StatefulWidget {
  const DateInputScreen({super.key});

  @override
  State<DateInputScreen> createState() => _DateInputScreenState();
}

class _DateInputScreenState extends State<DateInputScreen> {
  @override
  void initState() {
    super.initState();
  }

  final CalendarController controller = getIt<CalendarController>();
  final TextEditingController dateTimeController = TextEditingController();
  DateTime? birthday;
  final _dateFormKey = GlobalKey<FormFieldState>();
  final _thresholdFormKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Image.asset('assets/onboarding/small_calendar.png', width: 0.3 * width),
        const SizedBox(height: 80),
        TextFormField(
          key: _dateFormKey,
          controller: dateTimeController,
          keyboardType: TextInputType.datetime,
          inputFormatters: [dateMaskFormatter],
          decoration: InputDecoration(
            hintText: 'ДД.ММ.ГГГГ',
            labelText: 'Введите дату рождения',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () async {
                DateTime? pickedDateTime = await selectDateTimeInCalendar(
                    context,
                    firstDate: minDate,
                    lastDate: maxBirthDate,
                );

                if (pickedDateTime != null) {
                  dateTimeController.text = formatDate(pickedDateTime);
                  birthday = pickedDateTime;
                }
              },
            ),
          ),
          validator: (String? dateTime) {
            if (dateTime != null && dateTime.isNotEmpty) {
              DateTime? convertedDateTime = convertStringToDateTime(dateTime, firstDate: minDate, lastDate: maxBirthDate);
              if (convertedDateTime == null) {
                return 'Недопустимое значение';
              }
              return null;
            } else {
              return 'Введите дату и время';
            }
          },
          onSaved: (String? dateTime) async {
            if (dateTime != null) {
              DateTime? convertedDateTime = convertStringToDateTime(dateTime);
              if (convertedDateTime != null) {
                birthday = convertedDateTime;
              }
            }
          },
          onFieldSubmitted: (String? dateTime) {
            if (_dateFormKey.currentState!.validate()) {
              birthday = convertStringToDateTime(dateTime!);
            }
          },
          // onTap: () {
          //   _thresholdFormKey.currentState!.save();
          // },
          onTapOutside: (PointerDownEvent pointerDownEvent) {
            _dateFormKey.currentState!.save();
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: _thresholdFormKey,
          keyboardType: TextInputType.number,
          initialValue: "80",
          decoration: const InputDecoration(
            helperText: 'Ожидаемое количество прожитых лет (до 90)',
          ),
          validator: (String? threshold) {
            if (threshold == null || threshold.isEmpty) {
              return "Введите значение";
            }
            int? thresholdValue = int.tryParse(threshold);
            if (thresholdValue == null) {
              return "Введите целое положительное число";
            } else {
              if (thresholdValue > 90) {
                return "Максимальный задаваемый возвраст - 90";
              }
              if (birthday == null) {
                return "Введите день рождения";
              } else {
                int age = calculateCurrentAge(birthday!);
                if (thresholdValue <= age) {
                  return "Количество прожитых лет слишком мало";
                } else {
                  return null;
                }
              }
            }
          },
          onSaved: (String? threshold) {
            if (_thresholdFormKey.currentState!.validate()) {
              userMaxAge = int.parse(threshold!);
            }
          },
          onTap: () {
            _dateFormKey.currentState!.save();
          },
          onTapOutside: (PointerDownEvent pointerDownEvent) {
            _thresholdFormKey.currentState!.save();
          },
          onFieldSubmitted: (String? threshold) {
            if (_thresholdFormKey.currentState!.validate()) {
              userMaxAge = int.parse(threshold!);
            }
          },
        ),
        const Spacer(),
        SizedBox(
          height: 52,
          width: 0.5 * width,
          child: ElevatedButton(
            onPressed: () {
              if (_dateFormKey.currentState!.validate()) {
                if (_thresholdFormKey.currentState!.validate()) {
                  _dateFormKey.currentState!.save();
                  _thresholdFormKey.currentState!.save();

                  if (birthday != null) {
                    controller.setBirthday(birthday!).then((value) => Navigator.pushReplacementNamed(context, '/'));
                    Navigator.pushReplacementNamed(context, '/');
                  }
                }
              }
            },
            child: const Text('ГОТОВО'),
          ),
        ),
      ],
    );
  }
}


