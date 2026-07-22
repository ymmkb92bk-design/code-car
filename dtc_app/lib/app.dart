import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'models/dtc_result.dart';
import 'models/search_outcome.dart';
import 'screens/ad_screen.dart';
import 'screens/consent_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/offline_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/rate_limited_screen.dart';
import 'screens/results_screen.dart';
import 'screens/search_screen.dart';
import 'services/ad_service.dart';
import 'services/connectivity_service.dart';
import 'services/consent_service.dart';
import 'services/device_id_service.dart';
import 'services/dtc_repository.dart';
import 'services/subscription_service.dart';
import 'theme/colors.dart';

enum _Screen { consent, search, ad, results, notFound, paywall, rateLimited }

/// Root state machine mirroring dtc-app-prototype.jsx's flow. Every screen
/// is a top-level widget class (never defined inside build()) — nesting
/// them would recreate the type identity on each rebuild and cost input
/// focus (Section 10 bug #1).
class DtcAppRoot extends StatefulWidget {
  const DtcAppRoot({super.key});

  @override
  State<DtcAppRoot> createState() => _DtcAppRootState();
}

class _DtcAppRootState extends State<DtcAppRoot> {
  final _repo = DtcRepository();
  final _ads = AdService();

  bool _bootstrapping = true;
  bool _hasAgreed = false;
  bool? _isOnline;
  String _deviceId = '';
  bool _isSubscriber = false;

  _Screen _screen = _Screen.search;
  String _lastCode = '';
  DtcResult? _result;
  bool _detailUnlocked = false;
  bool _watchingAd = false;

  StreamSubscription<bool>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    unawaited(_ads.initialize());
    _connectivitySub = ConnectivityService.onStatusChange.listen((online) {
      if (mounted) setState(() => _isOnline = online);
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final results = await Future.wait([
      ConsentService.hasAgreed(),
      ConnectivityService.checkNow(),
      DeviceIdService.getDeviceId(),
      SubscriptionService.isActive(),
    ]);
    if (!mounted) return;
    setState(() {
      _hasAgreed = results[0] as bool;
      _isOnline = results[1] as bool;
      _deviceId = results[2] as String;
      _isSubscriber = results[3] as bool;
      _bootstrapping = false;
    });
  }

  Future<void> _onAgree() async {
    await ConsentService.markAgreed();
    setState(() => _hasAgreed = true);
  }

  Future<void> _runSearch(String code, String? brand) async {
    setState(() {
      _screen = _Screen.ad;
      _lastCode = code;
      _detailUnlocked = _isSubscriber;
    });

    SearchOutcome outcome;
    try {
      outcome = await _repo.search(code: code, brand: brand, deviceId: _deviceId);
    } catch (e, st) {
      // Surface the real cause in the debug console instead of leaving the
      // ad screen spinning forever with no explanation.
      debugPrint('DTC search failed for "$code": $e\n$st');
      outcome = SearchOutcome.notFound();
    }

    if (!mounted) return;
    setState(() {
      switch (outcome.type) {
        case SearchOutcomeType.found:
          _result = outcome.result;
          _screen = _Screen.results;
          break;
        case SearchOutcomeType.notFound:
          _result = null;
          _screen = _Screen.notFound;
          break;
        case SearchOutcomeType.quotaExceeded:
          _screen = _Screen.paywall;
          break;
        case SearchOutcomeType.rateLimited:
          _screen = _Screen.rateLimited;
          break;
      }
    });
  }

  Future<void> _watchRewardedAd(BuildContext context) async {
    setState(() => _watchingAd = true);

    // Check the daily rewarded-ad cap (Section 6) BEFORE even attempting to
    // show the ad — fails open by design (see DtcRepository.registerAdView),
    // this only ever blocks in the rare case where the cap is genuinely hit.
    final allowed = await _repo.registerAdView(_deviceId);
    if (!allowed) {
      if (!mounted) return;
      setState(() => _watchingAd = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وصلت للحد اليومي من الإعلانات — حاول لاحقاً')),
      );
      return;
    }

    final earned = await _ads.showRewarded();
    if (!mounted) return;
    setState(() {
      _watchingAd = false;
      // Details unlock only on a genuine earned reward — never just on
      // tapping the button — matching Section 4.4's rewarded-ad gate.
      if (earned) _detailUnlocked = true;
    });
    if (!earned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('شاهد الإعلان كاملاً لفتح التفاصيل — حاول مرة أخرى')),
      );
    }
  }

  void _goSearchAgain() {
    setState(() {
      _result = null;
      _detailUnlocked = false;
      _screen = _Screen.search;
    });
  }

  /// Returning from the paywall/rate-limit screens doesn't play an ad —
  /// only an actual new search attempt does (Section 4.4, 4.5).
  void _backToSearchNoAd() {
    setState(() => _screen = _Screen.search);
  }

  void _onSubscribeTapped(BuildContext context) {
    // Placeholder until build-order step 7 (Google Play Billing) wires up a
    // real purchase flow.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('الاشتراك غير متاح بعد — قريباً')),
    );
  }

  Future<void> _shareResult() async {
    final r = _result;
    if (r == null) return;
    final text = '${r.code} - ${r.meaning}\n'
        'الخطورة: ${r.severity}\n\n'
        'حمّل التطبيق: play.google.com/store/apps/details?id=com.example.dtc_app';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline == false) {
      return OfflineScreen(onRetry: () async {
        final online = await ConnectivityService.checkNow();
        setState(() => _isOnline = online);
      });
    }

    if (_bootstrapping) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.amber)),
      );
    }

    if (!_hasAgreed) {
      return ConsentScreen(onAgree: _onAgree);
    }

    switch (_screen) {
      case _Screen.search:
        return SearchScreen(onSearch: _runSearch);
      case _Screen.ad:
        return const AdScreen();
      case _Screen.results:
        return ResultsScreen(
          result: _result!,
          detailUnlocked: _detailUnlocked,
          watchingAd: _watchingAd,
          onWatchAd: () => _watchRewardedAd(context),
          onSearchAgain: _goSearchAgain,
          onShare: _shareResult,
        );
      case _Screen.notFound:
        return NotFoundScreen(code: _lastCode, onSearchAgain: _goSearchAgain);
      case _Screen.paywall:
        return PaywallScreen(
          onBack: _backToSearchNoAd,
          onSubscribeTapped: () => _onSubscribeTapped(context),
        );
      case _Screen.rateLimited:
        return RateLimitedScreen(onBack: _backToSearchNoAd);
      case _Screen.consent:
        return ConsentScreen(onAgree: _onAgree);
    }
  }
}
