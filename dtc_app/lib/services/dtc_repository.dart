import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dtc_result.dart';
import '../models/search_outcome.dart';

/// All search/ad-view traffic goes through the search_dtc / register_ad_view
/// Postgres RPCs (see supabase/schema.sql) — never direct table access.
/// Those functions run SECURITY DEFINER and enforce rate limiting, the
/// 3/day quota, and search logging atomically server-side (Section 5, 6).
class DtcRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<SearchOutcome> search({
    required String code,
    required String? brand,
    required String deviceId,
  }) async {
    final response = await _client.rpc('search_dtc', params: {
      'p_device_id': deviceId,
      'p_code': code,
      'p_brand': brand,
    });

    final map = response as Map<String, dynamic>;
    if (map['error'] == 'rate_limited') return SearchOutcome.rateLimited();
    if (map['quota_exceeded'] == true) return SearchOutcome.quotaExceeded();
    if (map['found'] == true) return SearchOutcome.found(DtcResult.fromRow(map));
    return SearchOutcome.notFound();
  }

  /// Registers a rewarded-ad view against the per-device daily cap.
  /// Fails open (treats as allowed) on any error — a backend hiccup here
  /// must not block a real user from seeing content they've already
  /// "paid" for by watching the ad.
  Future<bool> registerAdView(String deviceId) async {
    try {
      final response = await _client.rpc('register_ad_view', params: {'p_device_id': deviceId});
      final map = response as Map<String, dynamic>;
      return map['allowed'] != false;
    } catch (_) {
      return true;
    }
  }

  /// Self-service data deletion (PDPL right to deletion) — wipes this
  /// device's search history, usage/quota record, and subscription record.
  /// Returns false on any error so the UI can show a real failure message
  /// rather than falsely claiming success.
  Future<bool> deleteMyData(String deviceId) async {
    try {
      final response = await _client.rpc('delete_my_data', params: {'p_device_id': deviceId});
      final map = response as Map<String, dynamic>;
      return map['success'] == true;
    } catch (_) {
      return false;
    }
  }
}
