import 'package:authentication/auth_repository.dart';
import 'package:authentication/bloc/auth_bloc.dart';
import 'package:authentication/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/utils/widgets/app_version_text_widget.dart';
import 'package:life_calendar/views/auth/login_screen.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:life_calendar/utils/utility_variables.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    User user = getIt.get<AuthRepository>().currentUser;

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), bottomRight: Radius.circular(16.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.status == AuthStatus.authenticated && state.user.name != null)
                          Text(user.name!),
                        if (state.status == AuthStatus.authenticated && state.user.email != null)
                          Text(user.email!),
                      ],
                    );
                  },
                ),
                Text("Дата рождения", style: Theme.of(context).textTheme.titleLarge,),
                FutureBuilder(
                  future: _getBirthday(),
                  builder: (BuildContext context, AsyncSnapshot<DateTime?> snapshot) {
                    if (snapshot.hasData) {
                      DateTime birthday = snapshot.data!;
                      return Text("${birthday.day}.${birthday.month}.${birthday.year}", style: Theme.of(context).textTheme.titleLarge);
                    } else {
                      return const Text("Не найдено");
                    }
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text("Связь с разработчиком"),
            onTap: () => Navigator.pushNamed(context, '/thanks'),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text("Политика конфиденциальности"),
            onTap: () async {
              final Uri url = Uri.parse(privacyPolicyUrl);
              OverlayState overlayState = Overlay.of(context);
              if (!await launchUrl(url)) {
                _showTopErrorSnackBar(overlayState);
              }
            },
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ListTile(
                    leading: Icon(state.status == AuthStatus.unauthenticated ? Icons.login : Icons.logout),
                    title: Text(state.status == AuthStatus.unauthenticated ? "Войти" : "Выйти"),
                    trailing: const AppVersionTextWidget(),
                    onTap: () {
                      if (state.status == AuthStatus.unauthenticated) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                      } else {
                        getIt.get<AuthRepository>().logout();
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTopErrorSnackBar(OverlayState overlayState) {
    showTopSnackBar(
      overlayState,
      const CustomSnackBar.error(
        message: "Ошибка перехода к политике конфиденциальности",
        icon: Icon(Icons.error_outline, size: 0),
      ),
    );
  }

  Future<DateTime?> _getBirthday() async {
    final prefs = await SharedPreferences.getInstance();
    final int? birthdayMilliseconds = prefs.getInt('birthday');

    if (birthdayMilliseconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(birthdayMilliseconds);
    }
    return null;
  }
}