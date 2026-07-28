import 'package:life_calendar/data/repositories/onboarding_repository/onboarding_repository.dart';
import 'package:life_calendar/domain/models/onboarding/onboarding_page.dart';
import 'package:life_calendar/utils/result.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl();

  @override
  Future<Result<List<OnboardingPage>>> getPages({
    bool isFullOnboarding = true,
  }) {
    return Future.value(
      Result.ok([
        if (isFullOnboarding)
          OnboardingPage(
            image: 'assets/onboarding/life_calendar_paper.png',
            titleResolver: (l10n) => l10n.onboardingTitleWelcome,
            contentResolver: (l10n) => l10n.onboardingContentWelcome,
          ),
        if (isFullOnboarding)
          OnboardingPage(
            image: 'assets/onboarding/life_calendar_arrows.png',
            titleResolver: (l10n) => l10n.onboardingTitleGrid,
            contentResolver: (l10n) => l10n.onboardingContentGrid,
          ),
        if (!isFullOnboarding)
          OnboardingPage(
            image: 'assets/onboarding/life_calendar_paper.png',
            titleResolver: (l10n) => l10n.onboardingTitle3v,
            contentResolver: (l10n) => l10n.onboardingContent3v,
          ),
        OnboardingPage(
          image: 'assets/onboarding/zoom_select.png',
          titleResolver: (l10n) => l10n.onboardingTitleZoom,
          contentResolver: (l10n) => l10n.onboardingContentZoom,
        ),
        OnboardingPage(
          image: 'assets/onboarding/current_week_swipe.png',
          titleResolver: (l10n) => l10n.onboardingTitleJumpToCurrentWeek,
          contentResolver: (l10n) => l10n.onboardingContentJumpToCurrentWeek,
        ),
        OnboardingPage(
          image: 'assets/onboarding/search_swipe.png',
          titleResolver: (l10n) => l10n.onboardingTitleSearch,
          contentResolver: (l10n) => l10n.onboardingContentSearch,
        ),
        OnboardingPage(
          image: 'assets/onboarding/side_menu_swipe.png',
          titleResolver: (l10n) => l10n.onboardingTitleSideMenu,
          contentResolver: (l10n) => l10n.onboardingContentSideMenu,
        ),
      ]),
    );
  }
}
