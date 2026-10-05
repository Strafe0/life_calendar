import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:life_calendar/core/extensions/date_time/date_time_extension.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_assessment/week_assessment_widget.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_events/week_event_list_widget.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_fab/week_fab.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_fab/week_fab_state_provider.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_goals/week_goal_list_widget.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_photos/week_photo_list_widget.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_resume/week_resume_widget.dart';

class WeekView extends StatelessWidget {
  const WeekView({super.key, required this.week});

  final Week week;

  @override
  Widget build(BuildContext context) {
    return WeekFabStateProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${context.l10n.week} '
            '${week.start.toLocalString(context)} '
            '- ${week.end.toLocalString(context)}',
          ),
          titleSpacing: 0,
          leadingWidth: 48,
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: const Padding(
          padding: EdgeInsets.zero,
          child: WeekFab(),
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(top: 20),
                  sliver: SliverToBoxAdapter(child: WeekAssessmentWidget()),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(top: 20),
                  sliver: WeekGoalListWidget(),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(top: 20),
                  sliver: WeekEventListWidget(),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(top: 20),
                  sliver: WeekPhotoListWidget(),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  sliver: WeekResumeWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
