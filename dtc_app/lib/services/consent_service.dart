import 'package:shared_preferences/shared_preferences.dart';

/// Local "already agreed" persistence (Section 4.1) — once agreed, never
/// show the consent screen again on that device.
class ConsentService {
  static const _prefsKey = 'consent_agreed';

  static Future<bool> hasAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  static Future<void> markAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }
}
