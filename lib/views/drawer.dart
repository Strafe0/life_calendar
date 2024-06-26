import 'package:flutter/material.dart';
import 'package:life_calendar/utils/utility_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.7,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Дата рождения",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  FutureBuilder(
                    future: _getBirthday(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DateTime?> snapshot) {
                      if (snapshot.hasData) {
                        DateTime birthday = snapshot.data!;
                        return Text(
                            "${birthday.day}.${birthday.month}.${birthday.year}",
                            style: Theme.of(context).textTheme.titleLarge);
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
                if (!await launchUrl(url)) {
                  if (!context.mounted) return;
                  _showTopErrorSnackBar(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTopErrorSnackBar(BuildContext context) {
    showTopSnackBar(
      Overlay.of(context),
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