import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';

Future<DateTime?> showAdaptiveDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  if (!Platform.isIOS) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  DateTime? tempPickedDate = initialDate ?? firstDate;

  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => Container(
      height: 300,
      padding: const EdgeInsets.only(top: 6),
      // Background color should adapt to the dark/light theme
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  child: Text(context.l10n.ready),
                  onPressed: () {
                    Navigator.of(context).pop(tempPickedDate);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: firstDate,
                minimumDate: firstDate,
                maximumDate: lastDate,
                onDateTimeChanged: (newDate) {
                  tempPickedDate = newDate;
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
