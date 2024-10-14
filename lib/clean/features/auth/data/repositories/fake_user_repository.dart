import 'package:life_calendar/clean/features/auth/data/repositories/user_repository.dart';

class FakeUserRepository implements UserRepository {
  @override
  DateTime getBirthdate() {
    return DateTime(1998, 12, 22);
  }

  @override
  int getLifeSpan() {
    return 85;
  }
}