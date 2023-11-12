import 'package:authentication/auth_repository.dart';
import 'package:authentication/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/views/auth/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход'),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider(
          create: (_) => LoginCubit(getIt.get<AuthRepository>()),
          child: const LoginForm(),
        ),
      ),
    );
  }
}
