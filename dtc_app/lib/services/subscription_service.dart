/// Stub until build-order step 7 (Google Play Billing integration) wires this
/// to a real `users.subscription_status` check. Subscribers skip the
/// rewarded-ad gate on the results screen (Section 4.4) and never see the
/// soft paywall (Section 5).
class SubscriptionService {
  static Future<bool> isActive() async => false;
}
