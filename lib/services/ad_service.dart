import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._internal();
  static final AdService instance = AdService._internal();

  bool _isInitialized = false;
  RewardedAd? _rewardedAd;
  bool _isLoadingRewardedAd = false;
  int _rewardedAdRetryAttempts = 0;
  static const int _maxRetryAttempts = 3;

  /// Test Ad Unit IDs provided by Google AdMob
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  /// Initialize Google Mobile Ads SDK and preload initial rewarded ad
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('[AdService] MobileAds initialized successfully');
      loadRewardedAd();
    } catch (e) {
      debugPrint('[AdService] Failed to initialize MobileAds: $e');
    }
  }

  /// Preload Rewarded Ad for instant display when needed
  void loadRewardedAd() {
    final adUnitId = rewardedAdUnitId;
    if (adUnitId.isEmpty || _isLoadingRewardedAd || _rewardedAd != null) {
      return;
    }

    _isLoadingRewardedAd = true;
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('[AdService] RewardedAd loaded successfully');
          _rewardedAd = ad;
          _isLoadingRewardedAd = false;
          _rewardedAdRetryAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('[AdService] RewardedAd failed to load: ${error.message} (code: ${error.code})');
          _rewardedAd = null;
          _isLoadingRewardedAd = false;
          _rewardedAdRetryAttempts++;
          if (_rewardedAdRetryAttempts < _maxRetryAttempts) {
            Future.delayed(
              Duration(seconds: 2 * _rewardedAdRetryAttempts),
              () => loadRewardedAd(),
            );
          }
        },
      ),
    );
  }

  /// Show Rewarded Ad. If ad is ready, display it and invoke callbacks.
  /// If ad is not ready, non-blockingly invoke [onAdDismissed] to keep UX smooth.
  void showRewardedAd({
    VoidCallback? onAdDismissed,
    Function(RewardItem reward)? onUserEarnedReward,
  }) {
    if (_rewardedAd == null) {
      debugPrint('[AdService] RewardedAd not ready, proceeding without ad.');
      loadRewardedAd();
      onAdDismissed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        debugPrint('[AdService] RewardedAd showed full screen content.');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('[AdService] RewardedAd dismissed full screen content.');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('[AdService] RewardedAd failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdDismissed?.call();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('[AdService] User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward?.call(reward);
      },
    );
  }

  /// Dispose any held ad resources
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
