import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Section 4.1. Deliberately a single vertically-centered flowing column —
/// NOT a top/bottom space-between layout, which was a real bug (Section 10
/// bug #3) that pinned the button far below the checkbox.
class ConsentScreen extends StatefulWidget {
  final VoidCallback onAgree;

  const ConsentScreen({super.key, required this.onAgree});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: const [
                      Text(
                        'أكواد الأعطال',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'دليلك السريع لفهم أكواد أعطال السيارة',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 17),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.panelRaised,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        Text(
                          'نجمع فقط: معرّف الجهاز، سجل عمليات البحث، وحالة الاشتراك — لتقديم الخدمة وتحسينها. لا نجمع اسمك أو موقعك.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 16, height: 1.7),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'المعلومات في هذا التطبيق لأغراض معلوماتية فقط، وليست بديلاً عن الفحص عند مركز متخصص. '
                          'لا نتحمل أي مسؤولية عن أي إصابة أو ضرر أو خسارة ناتجة عن استخدام هذه المعلومات.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.7),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => setState(() => _checked = !_checked),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _checked,
                          activeColor: AppColors.amber,
                          onChanged: (v) => setState(() => _checked = v ?? false),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(color: AppColors.textMuted, fontSize: 16, height: 1.7),
                                children: [
                                  TextSpan(text: 'بالمتابعة، أنت توافق على '),
                                  TextSpan(
                                    text: 'شروط الاستخدام',
                                    style: TextStyle(color: AppColors.amber, decoration: TextDecoration.underline),
                                  ),
                                  TextSpan(text: ' و'),
                                  TextSpan(
                                    text: 'سياسة الخصوصية',
                                    style: TextStyle(color: AppColors.amber, decoration: TextDecoration.underline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checked ? widget.onAgree : null,
                    child: const Text('موافق ومتابعة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
