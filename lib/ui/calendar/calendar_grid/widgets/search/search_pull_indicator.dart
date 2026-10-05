import 'package:flutter/material.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';

class SearchPullIndicator extends StatelessWidget {
  const SearchPullIndicator({
    super.key,
    required this.isSearchTriggered,
    required this.height,
  });

  final bool isSearchTriggered;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: isSearchTriggered
                    ? const Icon(
                        Icons.check_circle,
                        size: 24,
                        color: Colors.green,
                      )
                    : Icon(
                        Icons.arrow_circle_down_sharp,
                        size: 24,
                        color: ColorScheme.of(context).onSurface,
                      ),
              ),
              if (isSearchTriggered)
                Text(
                  context.l10n.releaseToSearch,
                  style: TextTheme.of(
                    context,
                  ).bodyMedium?.copyWith(color: Colors.green),
                )
              else
                Text(context.l10n.pullToSearch),
            ],
          ),
        ),
      ),
    );
  }
}
