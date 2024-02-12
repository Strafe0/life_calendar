import 'package:flutter/material.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/utils/device_type.dart';
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
  Widget build(BuildContext context) {
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
            if (deviceType == DeviceType.phone) {
              calculateSizesForPhones(constraints.maxWidth, constraints.maxHeight);
            } else {
              calculateSizesForTablets(constraints.maxWidth, constraints.maxHeight);
            }

            return CalendarCanvas(weekRectHolder: weekRectHolder,);
          }
        ),
      ),
    );
  }

  void calculateSizesForPhones(double w, double h) {
    int N = 53, M = controller.numberOfYears;
    int k1 = 10, k2 = 15, k3 = 20;
    int m2 = 5, m3 = 4;

    double cHor = w / ((k1 + 1) * N + 2 * k2 + k3 - 1);

    weekBoxSide = k1 * cHor;
    weekBoxPaddingX = cHor;
    horPadding = k2 * cHor;
    labelHorPadding = k3 * cHor;

    weekBoxPaddingY = (h - M * weekBoxSide) / (M + 2 * m2 + m3 - 1);
    vrtPadding = m2 * weekBoxPaddingY;
    labelVrtPadding = m3 * weekBoxPaddingY;
  }

  void calculateSizesForTablets(double w, double h) {
    int N = 53, M = controller.numberOfYears;
    int k2 = 5, k3 = 6;
    int m1 = 10, m2 = 20, m3 = 15;

    double cVrt = h / ((m1 + 1) * M + 2 * m2 + m3 - 1);

    weekBoxSide = m1 * cVrt;
    weekBoxPaddingY = cVrt;
    vrtPadding = m2 * cVrt;
    labelVrtPadding = m3 * cVrt;

    weekBoxPaddingX = (w - N * weekBoxSide) / (N + 2 * k2 + k3 - 1);
    horPadding = k2 * weekBoxPaddingX;
    labelHorPadding = k3 * weekBoxPaddingX;
  }
}