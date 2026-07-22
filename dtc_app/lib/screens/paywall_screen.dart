import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Section 5 — soft paywall shown after the 3rd free search of the day.
/// Subscribe button is a placeholder until build-order step 7 (Google Play
/// Billing) wires up a real purchase flow.
class PaywallScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSubscribeTapped;

  const PaywallScreen({super.key, required this.onBack, required this.onSubscribeTapped});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.panelRaised,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(child: Text('🔒', style: TextStyle(fontSize: 26))),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'استخدمت بحثك المجاني لهذا اليوم',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.text, fontSize: 19, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'اشترك للحصول على بحث غير محدود بدون إعلانات، أو ارجع غداً لاستخدام بحثك المجاني.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.8),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onSubscribeTapped,
                child: const Text('اشترك الآن — ٥ ريال / شهرياً'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.panelRaised,
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.text,
                ),
                child: const Text('العودة للبحث'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
