import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/core/navigation/app_routes.dart';
import 'package:life_calendar/ui/core/snackbars/error_snack_bar.dart';
import 'package:life_calendar/ui/registration/bloc/registration_cubit.dart';
import 'package:life_calendar/ui/registration/bloc/registration_state.dart';
import 'package:life_calendar/ui/registration/widgets/registration_form_body.dart';
import 'package:life_calendar/ui/user/bloc/user_bloc.dart';
import 'package:life_calendar/ui/user/bloc/user_event.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegistrationCubit(
        authRepository: context.read(),
        weekRepository: context.read(),
        analytics: context.read(),
      ),
      child: Builder(
        builder: (context) {
          return BlocListener<RegistrationCubit, RegistrationState>(
            listener: (context, state) {
              switch (state) {
                case RegistrationSuccess():
                  context.read<UserBloc>().add(UserReceived(state.user));
                  context.go(AppRoute.calendar);
                case RegistrationFailure():
                  showErrorSnackBar(
                    context,
                    text: context.l10n.registrationUserError,
                  );
                case RegistrationCalendarFailure():
                  showErrorSnackBar(
                    context,
                    text: context.l10n.registrationCalendarError,
                  );
                default:
                  break;
              }
            },
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Image.asset('assets/calendar.png'),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: RegistrationFormBody(formKey: _formKey),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
