import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/theme.dart';

class Assessment extends StatefulWidget {
  const Assessment({super.key, required this.changeAssessment, required this.initialAssessment});

  final void Function(WeekAssessment assessment) changeAssessment;
  final WeekAssessment initialAssessment;

  @override
  State<Assessment> createState() => _AssessmentState();
}

class _AssessmentState extends State<Assessment> {
  WeekAssessment? assessment;

  @override
  void initState() {
    super.initState();
    assessment = widget.initialAssessment;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
          child: Text('Дайте оценку неделе', style: Theme.of(context).textTheme.titleMedium,),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                radioButton(WeekAssessment.good, goodWeekColor),
                radioButton(WeekAssessment.bad, badWeekColor),
                radioButton(WeekAssessment.poor, Theme.of(context).colorScheme.secondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget radioButton(WeekAssessment value, Color color) {
    return Column(
      children: [
        Radio(
          value: value,
          groupValue: assessment,
          fillColor: MaterialStatePropertyAll(color),
          onChanged: (WeekAssessment? newValue) {
            if (newValue != null) {
              setState(() {
                assessment = newValue;
                widget.changeAssessment(newValue);
              });
            }
          },
        ),
        Text(value.name, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}