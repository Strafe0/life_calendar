import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/constants/constants.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/ui/calendar/drawer/widgets/drawer_item.dart';
import 'package:life_calendar/ui/core/dialogs/alert_dialog.dart';
import 'package:life_calendar/ui/core/dialogs/dialog_action.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerThanks extends StatelessWidget {
  const DrawerThanks({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerItem(
      icon: Icons.favorite,
      iconColor: Colors.red,
      title: context.l10n.donate,
      onPressed: () async {
        unawaited(context.read<AnalyticsService>().logDonate(DonateStep.open));

        final userWantsSupport = await showAlertDialog<bool>(
          context,
          title: context.l10n.donateDialogTitle,
          content: context.l10n.donateDialogMessage,
          actions: [
            DialogAction(
              onPressed: (context) => Navigator.of(context).pop(false),
              title: context.l10n.donateDialogButtonNegative,
              color: ColorScheme.of(context).secondary.withValues(alpha: 0.5),
            ),
            DialogAction(
              onPressed: (context) {
                unawaited(
                  context.read<AnalyticsService>().logDonate(
                    DonateStep.goToDonation,
                  ),
                );

                Navigator.of(context).pop(true);
              },
              title: context.l10n.donateDialogButtonPositive,
              color: Colors.green,
            ),
          ],
        );

        if (userWantsSupport ?? false) {
          final url = Uri.parse(donateLink);

          try {
            await launchUrl(url);
          } catch (e) {
            logger.e('Failed to open Donate link', error: e);

            if (!context.mounted) return;

            await showAlertDialog(
              context,
              title: context.l10n.error,
              content: context.l10n.errorHappened,
              actions: [
                DialogAction(
                  onPressed: (context) => Navigator.of(context).pop(),
                  title: context.l10n.tryAgainLater,
                ),
              ],
            );
          }
        }
      },
    );
  }
}
