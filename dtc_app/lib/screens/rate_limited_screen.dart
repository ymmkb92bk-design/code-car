import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Shown on the rare "too many requests/minute" anti-abuse rate limit
/// (Section 6) — not a normal user-facing state, just a safety net.
class RateLimitedScreen extends StatelessWidget {
  final VoidCallback onBack;

  const RateLimitedScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'طلبات كثيرة جداً',
                        style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'حاول مرة أخرى بعد قليل.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.8),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(onPressed: onBack, child: const Text('العودة للبحث')),
            ],
          ),
        ),
      ),
    );
  }
}
