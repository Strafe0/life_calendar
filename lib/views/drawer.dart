import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/models/calendar_model.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/utils/snackbar.dart';
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
                          DateFormat("dd.MM.yyyy").format(birthday),
                          style: Theme.of(context).textTheme.titleLarge,
                        );
                      } else {
                        return const Text("Не найдено");
                      }
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: const Text("Экспорт календаря"),
              onTap: () {
                _showExportDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text("Импорт календаря"),
              onTap: () {
                _showImportDialog(context);
              },
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

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Экспорт данных приложения"),
          content: FutureBuilder<File?>(
            future: getIt<CalendarController>().exportCalendar(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.none) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    Text("Происходит создание архива."),
                  ],
                );
              } else {
                if (snapshot.hasData) {
                  return const Text("Архив успешно создан.");
                } else {
                  log("Snapshot is empty", error: snapshot.error, stackTrace: snapshot.stackTrace);
                  return const Text("Произошла ошибка при создании архива. Попробуйте снова.");
                }
              }
            }
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Ок"),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Импорт данных приложения"),
          content: const Text("При импорте календаря все ваши текущие данные "
              "будут удалены и заменены новыми! "
              "Убедитесь, что старые данные вам не нужны, или сделайте экспорт. "
              "После импорта вам нужно будет перезайти в приложение."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена"),
            ),
            TextButton(
              onPressed: () async {
                ImportResult result = await getIt<CalendarController>().importCalendar();
                if (result == ImportResult.success) {
                  exit(0);
                } else if (result == ImportResult.cancel) {
                  if (!context.mounted) return;
                  Navigator.pop(context);

                  showSnackBar(context, "Импорт отменен");
                } else {
                  if (!context.mounted) return;
                  showSnackBar(context, "Произошла ошибка во время импорта");
                }
              },
              child: const Text("Продолжить"),
            ),
          ],
        );
      },
    );
  }
}