import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/calendar/year.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/utils.dart';
import 'package:life_calendar/setup.dart';
import 'package:provider/provider.dart';

double weekBoxSide = 6;
double weekBoxPadding = 0.5;

class CalendarWidget extends StatelessWidget {
  CalendarWidget({Key? key}) : super(key: key);

  final CalendarController controller = getIt<CalendarController>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    debugPrint('screen width: $screenWidth');
    calculateSizes(screenWidth);

    return ChangeNotifierProvider.value(
      value: controller,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, top: 4.0, bottom: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildChildren(),
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    List<Widget> result = [];
    // result.add(const Align(alignment: Alignment.centerLeft, child: Text('Недели ->')));
    List<Widget> weekIndexRow = [];

    for (int i = 0; i < maxWeekNumber+1; i++) {
      bool isDivisibleBy5 = i % 5 == 0 && i != 0 ? true : false;
      weekIndexRow.add(Opacity(
        opacity: isDivisibleBy5 || i == 1 ? 1.0 : 0.0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: weekBoxPadding),
          child: SizedBox(
            height: weekBoxSide,
            width: i == 0 ? weekBoxSide * 2 : weekBoxSide,
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

    for (Year year in controller.allYears) {
      result.add(YearRow(year, year.weeks));
    }
    return result;
  }

  void calculateSizes(double screenWidth) {
    int width = screenWidth.round();
    // weekBoxPadding = (width - 16) / 636;
    weekBoxPadding = (width - 28) / 636;
    // weekBoxPadding = double.parse(((width - 16) / 636).toStringAsFixed(1));
    weekBoxSide = weekBoxPadding * 10;

    debugPrint('weekBoxPadding: $weekBoxPadding');
    debugPrint('weekBoxSide: $weekBoxSide');
  }
}

class YearRow extends StatelessWidget {
  const YearRow(this.year, this.weeks, {Key? key}) : super(key: key);

  final Year year;
  final List<Week> weeks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      // mainAxisSize: MainAxisSize.min,
      children: _buildChildren(),
    );
  }

  List<Widget> _buildChildren() {
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

    for (var week in weeks) {
      result.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: weekBoxPadding),
        child: WeekBox(week.id, week.yearId),
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
    return Consumer<CalendarController>(
      builder: (context, controller, child) {
        final Color weekColor = controller.getWeekColor(widget.id, widget.yearId, Theme.of(context).brightness);

        return SizedBox(
          width: weekBoxSide,
          height: weekBoxSide,
          child: ElevatedButton(
            onPressed: () {
              controller.selectWeek(widget.id, widget.yearId);
              Navigator.pushNamed(context, '/weekInfo');
            },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(weekColor),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1.5),
                side: BorderSide(color: weekColor),
              )),
              elevation: const MaterialStatePropertyAll(0),
            ),
            child: Container(),
          ),
        );
      },
    );
  }
}