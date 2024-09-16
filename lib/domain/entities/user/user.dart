import 'level.dart';

class User {
  const User({
    required this.id,
    this.name,
    this.email,
    required this.birthDate,
    required this.lifeSpan,
    this.level = Level.basic,
  });

  final String id;
  final String? name;
  final String? email;
  final int birthDate;
  final int lifeSpan;
  final Level level;
}
