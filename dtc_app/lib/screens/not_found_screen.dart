import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Section 4.5. Exactly one action button — a duplicated second "search
/// again" button here was a real bug (Section 10 bug #4). Never tell the
/// user their search was "logged" — that happens silently server-side.
class NotFoundScreen extends StatelessWidget {
  final String code;
  final VoidCallback onSearchAgain;

  const NotFoundScreen({super.key, required this.code, required this.onSearchAgain});

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
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          code,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontFamily: 'Courier New',
                            fontSize: 22,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Column(
                            children: const [
                              Text(
                                'لم نجد هذا الكود بعد',
                                style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'نعمل على إضافة المزيد من الأكواد باستمرار.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(onPressed: onSearchAgain, child: const Text('بحث عن كود آخر')),
            ],
          ),
        ),
      ),
    );
  }
}
