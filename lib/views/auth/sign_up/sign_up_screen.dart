import 'package:authentication/auth_repository.dart';
import 'package:authentication/cubit/sign_up/sign_up_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/views/auth/sign_up/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const SignUpScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocProvider<SignUpCubit>(
          create: (_) => SignUpCubit(getIt.get<AuthRepository>()),
          child: const SignUpForm(),
        ),
      ),
    );
  }
}
