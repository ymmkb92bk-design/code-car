import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Produces a per-device identifier for daily-quota tracking (Section 3, 5).
///
/// Prefers a platform hardware-derived id (Android's ANDROID_ID, iOS's
/// identifierForVendor) since those survive an app reinstall — matching the
/// spec's "at least somewhat resistant" requirement. Falls back to a
/// locally-generated UUID cached in shared_preferences on platforms where
/// that isn't available (the fallback does NOT survive reinstall; accepted
/// tradeoff per Section 5).
class DeviceIdService {
  static const _prefsKey = 'device_id_fallback_uuid';
  static String? _cached;

  static Future<String> getDeviceId() async {
    if (_cached != null) return _cached!;

    final plugin = DeviceInfoPlugin();
    String? id;

    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        id = info.id;
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        id = info.identifierForVendor;
      }
    } catch (_) {
      id = null;
    }

    if (id == null || id.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      id = prefs.getString(_prefsKey);
      if (id == null) {
        id = const Uuid().v4();
        await prefs.setString(_prefsKey, id);
      }
    }

    _cached = id;
    return id;
  }
}
