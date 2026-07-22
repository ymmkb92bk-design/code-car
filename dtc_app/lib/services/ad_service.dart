import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';

/// Manages loading and showing the rewarded ad (unlock-details, Section
/// 4.4) — the app's only ad placement. Ads are purely opt-in: no forced
/// interstitial on search or "search again" (revised after testing —
/// stacking a forced ad on every search felt like a wall of ads and risked
/// hurting retention/ratings for little extra revenue). The ad is preloaded
/// so it's ready the moment it's needed; a load in progress or a failure
/// never blocks the app's core flow.
class AdService {
  RewardedAd? _rewardedAd;
  bool _loadingRewarded = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadRewarded();
  }

  void _loadRewarded() {
    if (_loadingRewarded) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _loadingRewarded = false;
        },
      ),
    );
  }

  /// Shows the rewarded ad if ready. Returns true only if the user actually
  /// earned the reward (watched it through) — details unlock only on a
  /// genuine earned reward, never just on tapping the button.
  Future<bool> showRewarded() async {
    final ad = _rewardedAd;
    if (ad == null) {
      _loadRewarded();
      return false;
    }
    _rewardedAd = null;

    final completer = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    await ad.show(onUserEarnedReward: (ad, reward) => earned = true);
    return completer.future;
  }
}
