import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A "قيّم التطبيق؟" prompt (native in-app review, not a custom dialog)
/// shown after a successful (found) result — never on the user's very
/// first-ever successful search, and never right after a
/// not-found/frustrating moment.
///
/// Re-asks periodically (every [_promptInterval]th qualifying success)
/// rather than just once — there's no API to detect whether the user
/// actually completed a rating (Google hides this deliberately), so
/// "ask until they rate" isn't literally possible. Calling this
/// repeatedly is safe: Google Play's own review API enforces its own
/// internal cooldown on how often the real dialog can appear to any one
/// user, regardless of how often the app requests it.
///
/// Note: the native dialog generally only appears for apps installed
/// through the Play Store — during `flutter run` sideloaded testing,
/// `isAvailable()`/`requestReview()` often silently no-op even when this
/// code runs correctly. The debugPrint below confirms whether that's
/// what's happening.
class RatePromptService {
  static const _successCountKey = 'successful_search_count';
  static const _promptInterval = 5;

  static Future<void> maybePromptAfterSuccess({required bool precededByNotFound}) async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_successCountKey) ?? 0) + 1;
    await prefs.setInt(_successCountKey, count);

    if (count < 2 || precededByNotFound) return;
    if ((count - 2) % _promptInterval != 0) return;

    final inAppReview = InAppReview.instance;
    final available = await inAppReview.isAvailable();
    debugPrint('RatePromptService: count=$count, isAvailable=$available');
    if (available) {
      await inAppReview.requestReview();
    }
  }
}
