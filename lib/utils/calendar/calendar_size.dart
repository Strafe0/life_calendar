import 'package:equatable/equatable.dart';

class CalendarSize extends Equatable {
  final double weekBoxSide;
  final double weekBoxPaddingX;
  final double weekBoxPaddingY;
  final double vrtPadding;
  final double horPadding;
  final double labelVrtPadding;
  final double labelHorPadding;

  const CalendarSize({
    required this.weekBoxSide,
    required this.weekBoxPaddingX,
    required this.weekBoxPaddingY,
    required this.vrtPadding,
    required this.horPadding,
    required this.labelVrtPadding,
    required this.labelHorPadding,
  });

  factory CalendarSize.forPhone(double width, double height, int yearsCount) {
    final N = 53, M = yearsCount;
    const k1 = 10, k2 = 15, k3 = 20;
    const m2 = 5, m3 = 4;

    final cHor = width / ((k1 + 1) * N + 2 * k2 + k3 - 1);

    final weekBoxSide = k1 * cHor;
    final weekBoxPaddingX = cHor;
    final horPadding = k2 * cHor;
    final labelHorPadding = k3 * cHor;

    final weekBoxPaddingY = (height - M * weekBoxSide) / (M + 2 * m2 + m3 - 1);
    final vrtPadding = m2 * weekBoxPaddingY;
    final labelVrtPadding = m3 * weekBoxPaddingY;

    return CalendarSize(
      weekBoxSide: weekBoxSide,
      weekBoxPaddingX: weekBoxPaddingX,
      weekBoxPaddingY: weekBoxPaddingY,
      vrtPadding: vrtPadding,
      horPadding: horPadding,
      labelVrtPadding: labelVrtPadding,
      labelHorPadding: labelHorPadding,
    );
  }

  factory CalendarSize.forTablet(double w, double h, int yearsCount) {
    final N = 53, M = yearsCount;
    const k2 = 5, k3 = 6;
    const m1 = 10, m2 = 20, m3 = 15;

    final cVrt = h / ((m1 + 1) * M + 2 * m2 + m3 - 1);

    final weekBoxSide = m1 * cVrt;
    final weekBoxPaddingY = cVrt;
    final vrtPadding = m2 * cVrt;
    final labelVrtPadding = m3 * cVrt;

    final weekBoxPaddingX = (w - N * weekBoxSide) / (N + 2 * k2 + k3 - 1);

    // In portrait a tablet can be too narrow for 53 columns at the size the
    // height allows, so fit the width instead.
    if (weekBoxPaddingX < weekBoxPaddingY) {
      return CalendarSize.forPhone(w, h, yearsCount);
    }

    final horPadding = k2 * weekBoxPaddingX;
    final labelHorPadding = k3 * weekBoxPaddingX;

    return CalendarSize(
      weekBoxSide: weekBoxSide,
      weekBoxPaddingX: weekBoxPaddingX,
      weekBoxPaddingY: weekBoxPaddingY,
      vrtPadding: vrtPadding,
      horPadding: horPadding,
      labelVrtPadding: labelVrtPadding,
      labelHorPadding: labelHorPadding,
    );
  }

  @override
  List<Object> get props => [
    weekBoxSide,
    weekBoxPaddingX,
    weekBoxPaddingY,
    vrtPadding,
    horPadding,
    labelVrtPadding,
    labelHorPadding,
  ];
}
