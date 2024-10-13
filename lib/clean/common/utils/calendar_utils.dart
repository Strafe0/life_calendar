class CalendarUtils {
  static int calculateWeeksAmountBetween(
    DateTime firstDate,
    DateTime secondDate,
  ) {
    return firstDate.difference(secondDate).inDays.abs() ~/ 7;
  }

  /// Вернет понедельник недели, содержащей переданную дату `date`.
  static DateTime mondayOfWeekContaining(DateTime date) {
    DateTime monday = date.copyWith();

    while (monday.weekday != DateTime.monday) {
      monday = monday.copyWith(day: monday.day - 1);
    }

    return monday;
  }

  /// Вернет воскресенье недели, содержащей переданную дату `date`.
  ///
  /// Вернет последнюю секунду воскресенья. Это нужно, чтобы корректно
  /// срабатывали сравнения дат. Например, чтобы
  /// `DateTime(2024, 10, 6, 14, 23, 55)`
  /// оказалось раньше, чем предполагаемый конец недели
  /// `DateTime(2024, 10, 6)`.
  static DateTime sundayOfWeekContaining(DateTime date) {
    DateTime sunday = date.copyWith();

    while (sunday.weekday != DateTime.sunday) {
      sunday = sunday.copyWith(day: sunday.day + 1);
    }

    return sunday.copyWith(hour: 23, minute: 59, second: 59);
  }
}
