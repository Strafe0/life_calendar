import 'dart:math';

import 'package:flutter/material.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/utils/utility_variables.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/views/calendar/calendar_canvas.dart';
import 'package:provider/provider.dart';
import 'package:life_calendar/views/calendar/week_rect_holder.dart';


class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  double screenWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  double screenHeight = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  final CalendarController controller = getIt<CalendarController>();

  final WeekRectHolder weekRectHolder = WeekRectHolder();

  @override
  void initState() {
    super.initState();
    calculateSizes2(screenWidth, screenHeight);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build CalendarWidget');
    debugPrint("AppBar height = ${Theme.of(context).appBarTheme.toolbarHeight}");
    debugPrint("AppBar height = ${AppBar().toolbarHeight}");
    debugPrint("toolbar height = $kToolbarHeight");
    debugPrint("NavBar height = $kBottomNavigationBarHeight");
    debugPrint("padding top = ${MediaQuery.of(context).padding.top}");
    debugPrint("padding top2 = ${WidgetsBinding.instance.platformDispatcher.views.first.padding.top}");

    return ChangeNotifierProvider.value(
      value: controller,
      child: GestureDetector(
        onTapUp: (details) {
          int? weekId = weekRectHolder.findWeekFromPoint(details.localPosition);

          if (weekId != null) {
            controller.selectWeek(weekId);
              Navigator.pushNamed(context, '/weekInfo')
                  .then((_) => setState(() {}));
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            debugPrint("width = $screenWidth, height = $screenHeight");
            debugPrint("constraints max width = ${constraints.maxWidth}");
            debugPrint("constraints min width = ${constraints.minWidth}");
            debugPrint("constraints max height = ${constraints.maxHeight}");
            debugPrint("constraints min height = ${constraints.minHeight}");
            calculateSizes2(constraints.maxWidth, constraints.maxHeight);
            return CalendarCanvas(weekRectHolder: weekRectHolder,);
          }
        ),
      ),
    );
  }

  /// 53 - number of weeks in row (maximal)
  /// 8 - left and right padding
  /// 
  /// `x` = 10 * `y`
  /// x + 53 * 2y + 8 * 2 = w
  void calculateSizes(double screenWidth, double screenHeight) {
    int width = screenWidth.round();
    double wWeekBoxPadding = (width - 28) / 636;

    int height = screenHeight.round();
    double hWeekBoxPadding = (height - 28) / 960;

    weekBoxPaddingX = wWeekBoxPadding < hWeekBoxPadding ? wWeekBoxPadding : hWeekBoxPadding;
    weekBoxSide = weekBoxPaddingX * 10;

    int n = controller.numberOfYears;
    weekBoxPaddingY = (height * 0.9 - 28 - n * weekBoxSide) / (2 * n);
  }

  void calculateSizes2(double screenWidth, double screenHeight) {
    int width = screenWidth.round();
    // int height = (screenHeight - kToolbarHeight).round();
    int height = screenHeight.round();
    // double devicePixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    // double paddingTop = WidgetsBinding.instance.platformDispatcher.views.first.padding.top;
    // int height = (screenHeight - kToolbarHeight / devicePixelRatio - paddingTop / devicePixelRatio).round();

    int N = 53;
    int M = controller.numberOfYears;

    double k = 10;
    double m = 3;
    double cW = width / ((k + 1) * N + 4 * k - 1);
    double a = k * cW;

    double cH = height / ((k + 1) * M + 4 * k - 1);
    double b = k * cH;

    if (a < b) {
      weekBoxSide = a;
      weekBoxPaddingX = cW;
      horPadding = a;
      vrtLabelWidth = 2 * a;

      weekBoxPaddingY = (height - M * a) / (M + 3 * m - 1);
      vrtPadding = m * weekBoxPaddingY;
      horLabelHeight = m * weekBoxPaddingY;
    } else {
      weekBoxSide = b;
      weekBoxPaddingY = cH;
      vrtPadding = b;
      horLabelHeight = 2 * b;

      weekBoxPaddingX = (width - N * b) / (N + 4 * k - 1);
      horPadding = m * weekBoxPaddingX;
      vrtLabelWidth = m * weekBoxPaddingX;
    }
  }
}