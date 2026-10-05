import 'package:flutter/material.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';

class CurrentWeekIndicator extends StatelessWidget {
  const CurrentWeekIndicator({
    super.key,
    required this.isCurrentWeekTriggered,
    required this.height,
  });

  final bool isCurrentWeekTriggered;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: isCurrentWeekTriggered
                    ? const Icon(
                        Icons.check_circle,
                        size: 24,
                        color: Colors.green,
                      )
                    : Icon(
                        Icons.arrow_circle_up_sharp,
                        size: 24,
                        color: ColorScheme.of(context).onSurface,
                      ),
              ),
              Text(
                context.l10n.pullToGoToCurrentWeek,
                style: TextTheme.of(context).bodyMedium?.copyWith(
                  color: isCurrentWeekTriggered
                      ? Colors.green
                      : ColorScheme.of(context).onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
