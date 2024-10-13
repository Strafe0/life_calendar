import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/clean/common/utils/calendar_utils.dart';

void main() {
  group('CalendarUtils.mondayOfWeekContaining', () {
    test('для воскресенья должен вернуть ближайший предществующий понедельник', () {
      // arrange
      DateTime sunday = DateTime(2024, 10, 6, 23, 59, 59);
      
      // act
      DateTime monday = CalendarUtils.mondayOfWeekContaining(sunday);
      
      // assert
      expect(sunday.weekday, equals(DateTime.sunday));
      expect(monday.weekday, equals(DateTime.monday));
      expect(monday, equals(DateTime(2024, 9, 30, 23, 59, 59)));
    });
    
    test('для понедельника должен вернуть этот же день', () {
      // arrange
      DateTime initMonday = DateTime(2024, 10, 7);

      // act
      DateTime monday = CalendarUtils.mondayOfWeekContaining(initMonday);

      // assert
      expect(initMonday.weekday, equals(DateTime.monday));
      expect(monday.weekday, equals(DateTime.monday));
      expect(monday, equals(DateTime(2024, 10, 7)));
    });
  });
  
  group('CalendarUtils.sundayOfWeekContaining', () {
    test('для понедельника должен вернуть ближайшее следующее воскресенье '
        '(его последнюю секунду)', () {
      // arrange
      DateTime monday = DateTime(2024, 9, 30);
      
      // act
      DateTime sunday = CalendarUtils.sundayOfWeekContaining(monday);
      
      // assert
      expect(monday.weekday, equals(DateTime.monday));
      expect(sunday.weekday, equals(DateTime.sunday));
      expect(sunday, equals(DateTime(2024, 10, 6, 23, 59, 59)));
    });

    test('для воскресенья должен вернуть этот же день '
        '(его последнюю секунду)', () {
      // arrange
      DateTime initSunday = DateTime(2024, 10, 6);

      // act
      DateTime sunday = CalendarUtils.sundayOfWeekContaining(initSunday);

      // assert
      expect(initSunday.weekday, equals(DateTime.sunday));
      expect(sunday.weekday, equals(DateTime.sunday));
      expect(sunday, equals(DateTime(2024, 10, 6, 23, 59, 59)));
    });
  });
}