import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/ui/onboarding/bloc/onboarding_cubit.dart';

class OnboardingErrorView extends StatelessWidget {
  const OnboardingErrorView({super.key, required this.isFullOnboarding});

  final bool isFullOnboarding;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.errorHappened,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextButton(
            onPressed: () => context.read<OnboardingCubit>().loadPages(
              isFullOnboarding: isFullOnboarding,
            ),
            child: Text(context.l10n.tryAgain),
          ),
        ],
      ),
    );
  }
}
