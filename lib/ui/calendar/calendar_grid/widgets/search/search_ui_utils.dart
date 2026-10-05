import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/core/navigation/app_routes.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/search/search_sheet.dart';
import 'package:life_calendar/ui/core/widgets/bottom_sheet.dart';

Future<void> showSearchSheet(BuildContext context) async {
  await showDraggableBottomSheet(
    context,
    title: context.l10n.search,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SearchSheet(
          onSubmit: (weekId) {
            context.pop();

            if (weekId != -1) {
              context.read<AnalyticsService>().logWeekOpening(
                WeekTransitionEvent.search,
              );
              context.push(AppRoute.weekId(weekId));
            } else {
              logger.w('Week not found');
            }
          },
        ),
      );
    },
  );
}
