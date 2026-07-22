import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Section 4.3. Placeholder loading state — real AdMob banner/interstitial
/// wiring is build-order step 6. Every search triggers this, found or not.
class AdScreen extends StatelessWidget {
  final String label;

  const AdScreen({super.key, this.label = 'جاري تحميل النتيجة...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(color: AppColors.amber, strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
