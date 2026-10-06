import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/domain/models/user/user.dart';

void main() {
  final user = User(id: 'id', birthdate: DateTime(1990, 5, 15), lifeSpan: 80);

  group('age', () {
    final cases = {
      DateTime(1990, 5, 15): 0,
      DateTime(2026, 1, 1): 35,
      DateTime(2026, 4, 30): 35,
      DateTime(2026, 5, 14, 23, 59): 35,
      DateTime(2026, 5, 15): 36,
      DateTime(2026, 5, 16): 36,
      DateTime(2026, 6, 1): 36,
      DateTime(2026, 12, 31): 36,
    };

    for (final MapEntry(key: now, value: age) in cases.entries) {
      test('is $age on $now', () {
        expect(user.age(time: () => now), age);
      });
    }

    test('counts a leap day birthday from March 1 in common years', () {
      final leapling = user.copyWith(birthdate: DateTime(2000, 2, 29));

      expect(leapling.age(time: () => DateTime(2027, 2, 28)), 26);
      expect(leapling.age(time: () => DateTime(2027, 3, 1)), 27);
      expect(leapling.age(time: () => DateTime(2028, 2, 29)), 28);
    });
  });

  group('lastDate', () {
    test('is the day before the birthday after the lifespan', () {
      expect(user.lastDate, DateTime(2071, 5, 14));
    });

    test('moves to the previous year for a January 1 birthday', () {
      final newYear = user.copyWith(birthdate: DateTime(1990), lifeSpan: 60);

      expect(newYear.lastDate, DateTime(2050, 12, 31));
    });
  });

  test('isLifeSpanValid accepts only values within the bounds', () {
    expect(User.isLifeSpanValid(User.minLifeSpan - 1), isFalse);
    expect(User.isLifeSpanValid(User.minLifeSpan), isTrue);
    expect(User.isLifeSpanValid(80), isTrue);
    expect(User.isLifeSpanValid(User.maxLifeSpan), isTrue);
    expect(User.isLifeSpanValid(User.maxLifeSpan + 1), isFalse);
    expect(User.minLifeSpan, 60);
    expect(User.maxLifeSpan, 100);
  });

  test('empty user has no id', () {
    final empty = User.empty();

    expect(empty.isEmpty, isTrue);
    expect(empty.lifeSpan, 0);
    expect(user.isEmpty, isFalse);
  });
}
