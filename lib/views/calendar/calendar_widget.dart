import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/calendar/year.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/theme.dart';
import 'package:life_calendar/utils.dart';

class Calendar extends StatelessWidget {
  Calendar({Key? key}) : super(key: key);

  final CalendarController controller = CalendarController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: InteractiveViewer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildChildren(),
        ),
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.only(right: 8.0),
    //   child: Center(
    //     child: Column(
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 24.0),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.start,
    //             children: const [
    //               Text('Недели'),
    //               Icon(Icons.arrow_right_alt),
    //             ],
    //           ),
    //         ),
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Column(
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               children: const [
    //                 RotatedBox(quarterTurns: -1, child: Text('Годы')),
    //                 RotatedBox(quarterTurns: 1, child: Icon(Icons.arrow_right_alt)),
    //               ],
    //             ),
    //             Expanded(
    //               // child: GridView.custom(
    //               //   gridDelegate: SliverGridDelegate(),
    //               //   childrenDelegate: childrenDelegate,
    //               // ),
    //               child: GridView.count(
    //                 shrinkWrap: true,
    //                 crossAxisSpacing: 1,
    //                 mainAxisSpacing: 1,
    //                 crossAxisCount: 52,
    //                 children: List.generate(
    //                   widget.controller.numberOfWeeks,
    //                   (index) {
    //
    //                   },
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  List<Widget> _buildChildren() {
    List<Widget> result = [];
    result.add(const Align(alignment: Alignment.centerLeft, child: Text('Недели ->')));
    List<Widget> weekIndexRow = [];

    for (int i = 1; i < maxWeekNumber+1; i++) {
      bool isDivisibleBy5 = i % 5 == 0 ? true : false;
      weekIndexRow.add(SizedBox(
        width: weekBoxSide + weekBoxPadding * 2,
        child: Visibility(
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          visible: isDivisibleBy5,
          child: Text(
            i.toString(),
            style: TextStyle(fontSize: isDivisibleBy5 ? 8 : 4),
          ),
        ),
      ));
    }
    result.add(Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: Row(children: weekIndexRow,),
    ));

    for (Year year in controller.allYears) {
      result.add(YearRow(year.weeks));
    }
    return result;
  }
}

class YearRow extends StatelessWidget {
  const YearRow(this.weeks, {Key? key}) : super(key: key);

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

    for (var week in weeks) {
      result.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: weekBoxPadding),
        child: WeekBox(week),
      ));
    }
    return result;
  }
}


class WeekBox extends StatelessWidget {
  const WeekBox(this.week, {Key? key}) : super(key: key);
  final Week week;

  @override
  Widget build(BuildContext context) {
    final Color weekColor = week.state == WeekState.past
        ? pastWeekColor
        : week.state == WeekState.future
            ? futureWeekColor
            : currentWeekColor;

    return SizedBox(
      width: weekBoxSide,
      height: weekBoxSide,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Неделя ${week.start.day}.${week.start.month}.${week.start.year} - ${week.end.day}.${week.end.month}.${week.end.year}'),
                content: Text('Состояние: ${week.start}'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Ок')),
                ],
              );
            },
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(weekColor),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.0),
            side: BorderSide(color: weekColor),
          )),
        ),
        child: Container(),
      ),
    );
  }
}


