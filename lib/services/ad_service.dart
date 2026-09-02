import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._internal();
  static final AdService instance = AdService._internal();

  bool _isInitialized = false;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isLoadingRewardedInterstitialAd = false;
  int _rewardedRetryAttempts = 0;
  static const int _maxRetryAttempts = 3;

  /// AdMob App ID
  static const String appId = 'ca-app-pub-6710188887500528~9017649547';

  /// Live Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-6710188887500528/5292177470';
    } else if (Platform.isIOS) {
      // Fallback or iOS unit ID
      return 'ca-app-pub-6710188887500528/5292177470';
    }
    return '';
  }

  /// Live Rewarded Interstitial Ad Unit ID
  static String get rewardedInterstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-6710188887500528/2271639763';
    } else if (Platform.isIOS) {
      // Fallback or iOS unit ID
      return 'ca-app-pub-6710188887500528/2271639763';
    }
    return '';
  }

  /// Backward-compatibility getter for rewarded ad unit ID
  static String get rewardedAdUnitId => rewardedInterstitialAdUnitId;

  /// Initialize Google Mobile Ads SDK and preload initial rewarded interstitial ad
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('[AdService] MobileAds initialized successfully');
      loadRewardedInterstitialAd();
    } catch (e) {
      debugPrint('[AdService] Failed to initialize MobileAds: $e');
    }
  }

  /// Preload Rewarded Interstitial Ad for instant display when needed
  void loadRewardedInterstitialAd() {
    final adUnitId = rewardedInterstitialAdUnitId;
    if (adUnitId.isEmpty || _isLoadingRewardedInterstitialAd || _rewardedInterstitialAd != null) {
      return;
    }

    _isLoadingRewardedInterstitialAd = true;
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          debugPrint('[AdService] RewardedInterstitialAd loaded successfully');
          _rewardedInterstitialAd = ad;
          _isLoadingRewardedInterstitialAd = false;
          _rewardedRetryAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('[AdService] RewardedInterstitialAd failed to load: ${error.message} (code: ${error.code})');
          _rewardedInterstitialAd = null;
          _isLoadingRewardedInterstitialAd = false;
          _rewardedRetryAttempts++;
          if (_rewardedRetryAttempts < _maxRetryAttempts) {
            Future.delayed(
              Duration(seconds: 2 * _rewardedRetryAttempts),
              () => loadRewardedInterstitialAd(),
            );
          }
        },
      ),
    );
  }

  /// Alias for loadRewardedInterstitialAd
  void loadRewardedAd() => loadRewardedInterstitialAd();

  /// Show Rewarded Interstitial Ad. If ad is ready, display it and invoke callbacks.
  /// If ad is not ready, non-blockingly invoke [onAdDismissed] to keep UX smooth.
  void showRewardedInterstitialAd({
    VoidCallback? onAdDismissed,
    Function(RewardItem reward)? onUserEarnedReward,
  }) {
    if (_rewardedInterstitialAd == null) {
      debugPrint('[AdService] RewardedInterstitialAd not ready, proceeding without ad.');
      loadRewardedInterstitialAd();
      onAdDismissed?.call();
      return;
    }

    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) {
        debugPrint('[AdService] RewardedInterstitialAd showed full screen content.');
      },
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        debugPrint('[AdService] RewardedInterstitialAd dismissed full screen content.');
        ad.dispose();
        _rewardedInterstitialAd = null;
        loadRewardedInterstitialAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (RewardedInterstitialAd ad, AdError error) {
        debugPrint('[AdService] RewardedInterstitialAd failed to show: ${error.message}');
        ad.dispose();
        _rewardedInterstitialAd = null;
        loadRewardedInterstitialAd();
        onAdDismissed?.call();
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('[AdService] User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward?.call(reward);
      },
    );
  }

  /// Alias for showRewardedInterstitialAd to support existing calls
  void showRewardedAd({
    VoidCallback? onAdDismissed,
    Function(RewardItem reward)? onUserEarnedReward,
  }) {
    showRewardedInterstitialAd(
      onAdDismissed: onAdDismissed,
      onUserEarnedReward: onUserEarnedReward,
    );
  }

  /// Dispose any held ad resources
  void dispose() {
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
  }
}
