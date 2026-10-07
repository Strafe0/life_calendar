import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:life_calendar/core/time/time_source.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required DateTime birthdate,
    required int lifeSpan,
  }) = _User;

  const User._();

  factory User.empty() => _User(
    id: '',
    birthdate: DateTime.fromMillisecondsSinceEpoch(0),
    lifeSpan: 0,
  );

  bool get isEmpty => id.isEmpty;

  int age({TimeSource time = systemTime}) {
    final now = time();

    if (now.month < birthdate.month) {
      return now.year - birthdate.year - 1;
    } else if (now.month > birthdate.month) {
      return now.year - birthdate.year;
    } else if (now.day < birthdate.day) {
      return now.year - birthdate.year - 1;
    } else {
      return now.year - birthdate.year;
    }
  }

  DateTime get lastDate => DateTime(
    birthdate.year + lifeSpan + 1,
    birthdate.month,
    birthdate.day - 1,
  );

  static const minLifeSpan = 60;
  static const maxLifeSpan = 100;

  static bool isLifeSpanValid(int lifeSpan) =>
      User.minLifeSpan <= lifeSpan && lifeSpan <= User.maxLifeSpan;
}
