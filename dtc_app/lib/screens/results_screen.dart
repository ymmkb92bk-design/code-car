import 'package:flutter/material.dart';
import '../models/dtc_result.dart';
import '../theme/colors.dart';
import '../widgets/detail_block.dart';

/// Section 4.4.
class ResultsScreen extends StatelessWidget {
  final DtcResult result;
  final bool detailUnlocked;
  final bool watchingAd;
  final VoidCallback onWatchAd;
  final VoidCallback onSearchAgain;
  final VoidCallback onShare;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.detailUnlocked,
    required this.watchingAd,
    required this.onWatchAd,
    required this.onSearchAgain,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final sevColor = AppColors.severityColor(result.severity);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: onSearchAgain,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.panelRaised,
                        side: const BorderSide(color: AppColors.amberDim),
                        foregroundColor: AppColors.amber,
                      ),
                      child: const Text('← بحث جديد'),
                    ),
                    OutlinedButton(
                      onPressed: onShare,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.panelRaised,
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.text,
                      ),
                      child: const Text('مشاركة ⤴'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E13),
                    border: Border.all(color: AppColors.amberDim),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      result.code,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontFamily: 'Courier New',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.panelRaised,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.meaning, style: const TextStyle(color: AppColors.text, fontSize: 17, height: 1.7)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: sevColor.withOpacity(0.13),
                          border: Border.all(color: sevColor.withOpacity(0.33)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: sevColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              result.severity,
                              style: TextStyle(color: sevColor, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (!detailUnlocked)
                  OutlinedButton(
                    onPressed: watchingAd ? null : onWatchAd,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.amberDim, style: BorderStyle.solid),
                      foregroundColor: AppColors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(
                      watchingAd ? 'جاري عرض الإعلان...' : '▶ شاهد إعلان قصير لعرض التفاصيل الكاملة',
                    ),
                  ),
                if (detailUnlocked)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DetailBlock(
                        title: 'الأسباب المحتملة',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: result.causes
                              .map((c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text('•  $c', style: const TextStyle(color: AppColors.text, fontSize: 15.5, height: 1.5)),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DetailBlock(
                        title: 'ماذا تفعل',
                        child: Text(result.action, style: const TextStyle(color: AppColors.text, fontSize: 15.5, height: 1.9)),
                      ),
                      const SizedBox(height: 12),
                      DetailBlock(
                        title: 'علامات قد تلاحظها',
                        child: Text(result.symptoms, style: const TextStyle(color: AppColors.text, fontSize: 15.5, height: 1.9)),
                      ),
                    ],
                  ),
                const SizedBox(height: 18),
                const Text(
                  '⚠️ هذه المعلومات لأغراض معلوماتية فقط ولا تغني عن الفحص عند مركز متخصص',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.5, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
