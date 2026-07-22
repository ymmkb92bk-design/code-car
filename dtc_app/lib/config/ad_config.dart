/// Rewarded ad unit ID — the app's only ad placement (see AdService).
/// This is the real one from the developer's AdMob account. It serves REAL
/// ads: don't tap/watch it repeatedly during dev testing beyond what's
/// needed to confirm the flow works, and never tap the ad content itself
/// just to "check" it — self-clicks on your own real ads count as invalid
/// traffic and risk the AdMob account (Section 6).
///
/// Can still be overridden (e.g. back to Google's test unit — see
/// https://developers.google.com/admob/android/test-ads — for heavier
/// testing sessions) via:
///   flutter run --dart-define=ADMOB_REWARDED_UNIT_ID=xxxx
/// (or in dart_defines.json)
class AdConfig {
  AdConfig._();

  static const rewardedAdUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_UNIT_ID',
    defaultValue: 'ca-app-pub-5335304138389032/1112326131',
  );

  static bool get usingTestAds => rewardedAdUnitId == 'ca-app-pub-3940256099942544/5224354917';
}
