import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/year.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/utils.dart';
import 'package:life_calendar/setup.dart';
import 'package:provider/provider.dart';


class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  double screenWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  final CalendarController controller = getIt<CalendarController>();
  List<Widget> children = [
    const Center(child: Text('Загрузка')),
  ];

  @override
  void initState() {
    super.initState();
    calculateSizes(screenWidth);

    var window = WidgetsBinding.instance.platformDispatcher;
    window.onPlatformBrightnessChanged = () {
      children = [const Center(child: Text('Смена темы'),)];
      startCompute();
      WidgetsBinding.instance.handlePlatformBrightnessChanged();
    };

    startCompute();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build CalendarWidget');

    return ChangeNotifierProvider.value(
      value: controller,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, top: 4.0, bottom: 8.0),
        child: Consumer<CalendarController>(
          builder: (context, controller, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            );
          },
        ),
      ),
    );
  }

  void calculateSizes(double screenWidth) {
    int width = screenWidth.round();
    weekBoxPadding = (width - 28) / 636;
    weekBoxSide = weekBoxPadding * 10;
  }

  void startCompute() {
    Map<String, dynamic> arguments = {
      "allYears": controller.allYears,
      "screenWidth": screenWidth.round(),
    };
    compute(_buildChildren, arguments).then((resultChildren) {
      children = resultChildren;
      controller.calendarIsReady();
      debugPrint('build children finished');
    });
  }
}

List<Widget> _buildChildren(Map<String, dynamic> args) {
  List<Widget> result = [];
  List<Widget> weekIndexRow = [];

  List<Year> allYears = args["allYears"];
  int width = args["screenWidth"];
  double padding = (width - 28) / 636;
  double side = padding * 10;

  for (int i = 0; i < maxWeekNumber+1; i++) {
    bool isDivisibleBy5 = i % 5 == 0 && i != 0 ? true : false;
    weekIndexRow.add(Opacity(
      opacity: isDivisibleBy5 || i == 1 ? 1.0 : 0.0,
      child: Padding(
        padding: EdgeInsets.only(left: padding, right: padding, bottom: padding * 5),
        child: SizedBox(
          height: side,
          width: i == 0 ? side * 2 : side,
          child: OverflowBox(
            alignment: Alignment.center,
            maxWidth: double.infinity,
            child: Text(
              i.toString(),
              style: TextStyle(fontSize: isDivisibleBy5 || i == 1 ? 8 : 4),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              softWrap: false,
              maxLines: 1,
            ),
          ),
        ),
      ),
    ));
  }
  result.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: weekIndexRow,));

  for (Year year in allYears) {
    result.add(YearRow(year));
  }
  return result;
}

class YearRow extends StatelessWidget {
  const YearRow(this.year, {Key? key}) : super(key: key);

  final Year year;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: _buildYearChildren(year),
    );
  }

  List<Widget> _buildYearChildren(Year year) {
    List<Widget> result = [];

    bool divisibleBy5 = year.age % 5 == 0 ? true : false;
    result.add(Opacity(
      opacity: divisibleBy5 || year.age == 0 ? 1.0 : 0.0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: weekBoxPadding),
        child: SizedBox(
          height: weekBoxSide,
          width: weekBoxSide * 2,
          child: OverflowBox(
            alignment: Alignment.center,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Text(
              year.age.toString(),
              style: TextStyle(fontSize: divisibleBy5 || year.age == 0 ? 8 : 4),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              softWrap: false,
              maxLines: 1,
            ),
          ),
        ),
      ),
    ));

    for (var week in year.weeks) {
      result.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: weekBoxPadding),
        child: WeekBox(week.id, week.yearId, key: ValueKey('${week.yearId}:${week.id}'),),
      ));
    }
    return result;
  }
}

class WeekBox extends StatefulWidget {
  const WeekBox(this.id, this.yearId, {Key? key}) : super(key: key);
  final int id;
  final int yearId;
  // final Week week;

  @override
  State<WeekBox> createState() => _WeekBoxState();
}

class _WeekBoxState extends State<WeekBox> {
  @override
  Widget build(BuildContext context) {
    final CalendarController controller = getIt<CalendarController>();
    final Color weekColor = controller.getWeekColor(widget.id, widget.yearId, Theme.of(context).brightness);

    return SizedBox(
      width: weekBoxSide,
      height: weekBoxSide,
      child: ElevatedButton(
        onPressed: () {
          controller.selectWeek(widget.id, widget.yearId);
          Navigator.pushNamed(context, '/weekInfo').then((_) => setState(() {}));
        },
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(weekColor),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.5),
            // side: BorderSide(color: widget.id == 1313 ? Colors.white : Colors.transparent),
          )),
          elevation: const MaterialStatePropertyAll(0),
        ),
        child: Container(),
      ),
    );
  }
}