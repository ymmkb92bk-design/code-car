import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Section 4.6.
class OfflineScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const OfflineScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                  child: const Center(child: Text('📶', style: TextStyle(fontSize: 26))),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا يوجد اتصال بالإنترنت',
                  style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const Text(
                  'تحتاج لاتصال بالإنترنت لاستخدام التطبيق. تأكد من الاتصال وحاول مرة أخرى.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.8),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
