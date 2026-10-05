import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/ui/calendar/week_screen/bloc/week_cubit.dart';
import 'package:life_calendar/ui/calendar/week_screen/bloc/week_state.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_assessment/week_assessment_ui_extension.dart';

class WeekAssessmentWidget extends StatelessWidget {
  const WeekAssessmentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WeekCubit, WeekState, WeekAssessment>(
      selector: (state) {
        if (state is WeekSuccess) {
          return state.week.assessment;
        }
        logger.w('Return poor assessment, because week is not ready');
        return WeekAssessment.poor;
      },
      builder: (context, selectedAssessment) {
        void onAssessmentChanged(WeekAssessment newValue) {
          context.read<WeekCubit>().changeAssessment(newValue);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                context.l10n.rateWeek,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (Platform.isIOS)
              _CupertinoAssessmentSelector(
                selected: selectedAssessment,
                onChanged: onAssessmentChanged,
              )
            else
              _MaterialAssessmentSelector(
                selected: selectedAssessment,
                onChanged: onAssessmentChanged,
              ),
          ],
        );
      },
    );
  }
}

class _CupertinoAssessmentSelector extends StatelessWidget {
  final WeekAssessment selected;
  final ValueChanged<WeekAssessment> onChanged;

  const _CupertinoAssessmentSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: CupertinoSlidingSegmentedControl<WeekAssessment>(
          groupValue: selected,
          thumbColor: selected.color,
          backgroundColor:
              CardTheme.of(context).color ?? CupertinoColors.tertiarySystemFill,
          padding: const EdgeInsets.all(4),
          children: {
            for (final assessment in WeekAssessment.values)
              assessment: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  assessment.label(context.l10n),
                  textAlign: TextAlign.center,
                  style: TextTheme.of(context).bodyMedium?.copyWith(
                    color: selected == assessment
                        ? Colors.white
                        : ColorScheme.of(context).onSurface,
                    fontWeight: selected == assessment
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
          },
          onValueChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _MaterialAssessmentSelector extends StatelessWidget {
  final WeekAssessment selected;
  final ValueChanged<WeekAssessment> onChanged;

  const _MaterialAssessmentSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<WeekAssessment>(
          segments: WeekAssessment.values
              .map((assessment) {
                return ButtonSegment<WeekAssessment>(
                  value: assessment,
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      assessment.label(context.l10n),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected == assessment
                            ? Colors.white
                            : ColorScheme.of(context).onSurface,
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
          selected: {selected},
          onSelectionChanged: (newSet) => onChanged(newSet.first),
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            backgroundColor: ColorScheme.of(context).surface,
            foregroundColor: ColorScheme.of(context).onSurface,
            selectedBackgroundColor: selected.color,
            selectedForegroundColor: Colors.white,
            side: BorderSide(
              color: ColorScheme.of(context).secondary,
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
