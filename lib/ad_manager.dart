import 'dart:developer';
import 'dart:ui';

import 'package:yandex_mobileads/mobile_ads.dart';
import 'package:flutter/material.dart' show debugPrint;

class AdManager {
  late final Future<RewardedAdLoader> _adLoader;
  RewardedAd? _ad;

  void createRewardedAdLoader() {
    _adLoader = RewardedAdLoader.create(
      onAdLoaded: (RewardedAd rewardedAd) {
        // The ad was loaded successfully. Now you can show loaded ad
        _ad = rewardedAd;
      },
      onAdFailedToLoad: (error) {
        // Ad failed to load with AdRequestError.
        // Attempting to load a new ad from the onAdFailedToLoad() method is strongly discouraged.
        log("Ad failed to load", error: error);
      },
    );
  }

  Future<void> loadRewardedAd({int? age, Brightness? brightness}) async {
    final adLoader = await _adLoader;
    await adLoader.loadAd(
      adRequestConfiguration: AdRequestConfiguration(
        adUnitId: 'R-M-2265467-3',
        age: age,
        preferredTheme: brightness == Brightness.dark ? AdTheme.dark : AdTheme.light,
      ),
    ); // For debugging, you can use 'demo-rewarded-yandex'
  }

  Future<bool> showAd({int? age, Brightness? brightness}) async {
    _ad?.setAdEventListener(
      eventListener: RewardedAdEventListener(
        onAdShown: () {
          // Called when an ad is shown.
        },
        onAdFailedToShow: (error) {
          // Called when an ad failed to show.
          // Destroy the ad so you don't show the ad a second time.
          _ad?.destroy();
          _ad = null;

          // Now you can preload the next ad.
          loadRewardedAd(age: age, brightness: brightness);
        },
        onAdClicked: () {
          // Called when a click is recorded for an ad.
        },
        onAdDismissed: () {
          // Called when ad is dismissed.
          // Destroy the ad so you don't show the ad a second time.
          _ad?.destroy();
          _ad = null;

          // Now you can preload the next ad.
          loadRewardedAd(age: age, brightness: brightness);
        },
        onAdImpression: (impressionData) {
          // Called when an impression is recorded for an ad.
        },
        onRewarded: (Reward reward) {
          // Called when the user can be rewarded.
        },
      ),
    );

    await _ad?.show();
    final reward = await _ad?.waitForDismiss();
    if (reward != null) {
      debugPrint('got ${reward.amount} of ${reward.type}');
      return true;
    }

    return false;
  }
}