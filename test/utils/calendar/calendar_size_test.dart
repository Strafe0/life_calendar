import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/utils/calendar/calendar_size.dart';

void main() {
  const columns = 53;
  const years = [61, 81, 101];

  double contentWidth(CalendarSize size) =>
      columns * size.weekBoxSide +
      (columns - 1) * size.weekBoxPaddingX +
      2 * size.horPadding +
      size.labelHorPadding;

  double contentHeight(CalendarSize size, int rows) =>
      rows * size.weekBoxSide +
      (rows - 1) * size.weekBoxPaddingY +
      2 * size.vrtPadding +
      size.labelVrtPadding;

  group('forPhone', () {
    for (final (width, height) in [(390.0, 844.0), (360.0, 640.0)]) {
      for (final rows in years) {
        test('fills $width x $height with $rows years', () {
          final size = CalendarSize.forPhone(width, height, rows);

          expect(contentWidth(size), closeTo(width, 1e-9));
          expect(contentHeight(size, rows), closeTo(height, 1e-9));
          expect(size.weekBoxSide, closeTo(10 * size.weekBoxPaddingX, 1e-9));
          expect(size.weekBoxPaddingY, isPositive);
        });
      }
    }
  });

  group('forTablet', () {
    for (final rows in years) {
      test('fits the height in landscape with $rows years', () {
        final size = CalendarSize.forTablet(1024, 768, rows);

        expect(contentWidth(size), closeTo(1024, 1e-9));
        expect(contentHeight(size, rows), closeTo(768, 1e-9));
        expect(size.weekBoxSide, closeTo(10 * size.weekBoxPaddingY, 1e-9));
      });
    }

    // Portrait iPad mini, iPad and iPad Pro 13" calendar areas.
    for (final (width, height) in [
      (744.0, 1033.0),
      (820.0, 1080.0),
      (1032.0, 1276.0),
    ]) {
      for (final rows in years) {
        test('fits $width x $height with $rows years without overlap', () {
          final size = CalendarSize.forTablet(width, height, rows);

          expect(contentWidth(size), closeTo(width, 1e-9));
          expect(contentHeight(size, rows), closeTo(height, 1e-9));
          expect(size.weekBoxPaddingX, isPositive);
          expect(size.weekBoxPaddingY, isPositive);
        });
      }
    }
  });

  test('compares by value', () {
    expect(
      CalendarSize.forPhone(390, 844, 61),
      CalendarSize.forPhone(390, 844, 61),
    );
    expect(
      CalendarSize.forPhone(390, 844, 61),
      isNot(CalendarSize.forPhone(390, 844, 81)),
    );
  });
}
