import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/dtc_input_sanitizer.dart';
import '../widgets/brand_dropdown.dart';
import 'settings_screen.dart';

/// Section 4.2.
class SearchScreen extends StatefulWidget {
  final void Function(String code, String? brand) onSearch;

  const SearchScreen({super.key, required this.onSearch});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _code = '';
  String? _brand;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCodeChanged(String raw) {
    final sanitized = sanitizeDtcInput(raw, _code);
    setState(() => _code = sanitized);
    if (_controller.text != sanitized) {
      _controller.value = TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSearch = _code.length >= 5;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.panelRaised,
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.text,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.settings_outlined, size: 18, color: AppColors.textMuted),
                  label: const Text('الإعدادات', style: TextStyle(fontSize: 13)),
                ),
              ),
              const Text(
                'ابحث عن كود العطل',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'أدخل الرمز الذي ظهر على جهاز الفحص',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 18),
              ),
              const SizedBox(height: 28),
              const Text('رمز العطل (DTC)', style: TextStyle(color: AppColors.textMuted, fontSize: 18)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0E13),
                  border: Border.all(color: _code.isNotEmpty ? AppColors.amberDim : AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: _controller,
                    onChanged: _onCodeChanged,
                    maxLength: 5,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.amber,
                      fontFamily: 'Courier New',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      hintText: 'مثال: P0420',
                      // Distinctly muted/dim vs. real entered text (Section 10 bug #2).
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'يبدأ بـ P أو B أو C أو U فقط · بدون مسافات · بالإنجليزية',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 15),
              ),
              const SizedBox(height: 24),
              const Text('نوع السيارة (اختياري)', style: TextStyle(color: AppColors.textMuted, fontSize: 18)),
              const SizedBox(height: 8),
              BrandDropdown(
                selectedBrand: _brand,
                onChanged: (b) => setState(() => _brand = b),
              ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: canSearch ? () => widget.onSearch(_code, _brand) : null,
                child: const Text('بحث'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
