class SignUpWithEmailAndPasswordFailure implements Exception {
  const SignUpWithEmailAndPasswordFailure([
    this.message = "Возникла неизвестная ошибка",
  ]);

  final String message;

  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    return switch(code) {
      'email-already-in-use' => const SignUpWithEmailAndPasswordFailure('Аккаунт с таким email уже существует'),
      'invalid-email' => const SignUpWithEmailAndPasswordFailure('Некорректный адрес электронной почты'),
      'operation-not-allowed' => const SignUpWithEmailAndPasswordFailure('Операция не разрешена. Сообщите об ошибке разработчику'),
      'week-password' => const SignUpWithEmailAndPasswordFailure('Пароль недостаточно сложный'),
      _ => const SignUpWithEmailAndPasswordFailure(),
    };
  }
}

class SignInWithEmailAndPasswordFailure implements Exception {
  const SignInWithEmailAndPasswordFailure([this.message = "Возникла неизвестная ошибка"]);

  final String message;

  factory SignInWithEmailAndPasswordFailure.fromCode(String code) {
    return switch(code) {
      'invalid-email' => const SignInWithEmailAndPasswordFailure('Некорректный адрес электронной почты'),
      'user-disabled' => const SignInWithEmailAndPasswordFailure('Пользователь с данным email заблокирован'),
      'user-not-found' => const SignInWithEmailAndPasswordFailure('Пользователь с данным email не найден'),
      'wrong-password' => const SignInWithEmailAndPasswordFailure('Неверный пароль'),
      _ => const SignInWithEmailAndPasswordFailure(),
    };
  }
}

class LogInWithGoogleFailure implements Exception {
  const LogInWithGoogleFailure([this.message = "Возникла неизвестная ошибка"]);

  final String message;

  factory LogInWithGoogleFailure.fromCode(String code) {
    return switch(code) {
      'account-exists-with-different-credential' => const LogInWithGoogleFailure('Аккаунт с таким email уже существует'),
      'invalid-credential' => const LogInWithGoogleFailure('Учетные данные искажены или срок их действия истек'),
      'operation-not-allowed' => const LogInWithGoogleFailure('Вход с данным типом аккаунта не разрешен'),
      'user-disabled' => const LogInWithGoogleFailure('Пользователь с этими данными заблокирован'),
      'user-not-found' => const LogInWithGoogleFailure('Нет пользователя с таким email'),
      'wrong-password' => const LogInWithGoogleFailure('Неверный пароль'),
      'invalid-verification-code' => const LogInWithGoogleFailure('Неверный код'),
      'invalid-verification-id' => const LogInWithGoogleFailure('Неверный ID'),
      _ => const LogInWithGoogleFailure(),
    };
  }
}

class LogInWithEmailAndPasswordFailure implements Exception {
  const LogInWithEmailAndPasswordFailure([this.message = "Возникла неизвестная ошибка"]);

  final String message;

  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    return switch (code) {
      'invalid-email' => const LogInWithEmailAndPasswordFailure('Некорректный адрес электронной почты'),
      'user-disabled' => const LogInWithEmailAndPasswordFailure('Пользователь с данным email заблокирован'),
      'user-not-found' => const LogInWithEmailAndPasswordFailure('Пользователь с данным email не найден'),
      'wrong-password' => const LogInWithEmailAndPasswordFailure('Неверный пароль'),
      _ => const LogInWithEmailAndPasswordFailure(),
    };
  }
}

class LogoutFailure implements Exception {
  const LogoutFailure([this.message = "Возникла неизвестная ошибка"]);

  final String message;
}