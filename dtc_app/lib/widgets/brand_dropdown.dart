import 'package:flutter/material.dart';
import '../constants/brands.dart';
import '../theme/colors.dart';

/// Plain tap-to-select dropdown — no typing, no keyboard, selection only
/// from the fixed brand list.
class BrandDropdown extends StatefulWidget {
  final String? selectedBrand;
  final ValueChanged<String?> onChanged;

  const BrandDropdown({super.key, required this.selectedBrand, required this.onChanged});

  @override
  State<BrandDropdown> createState() => _BrandDropdownState();
}

class _BrandDropdownState extends State<BrandDropdown> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _open = !_open),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.panelRaised,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedBrand ?? 'اختر نوع السيارة',
                  style: TextStyle(
                    color: widget.selectedBrand != null ? AppColors.text : AppColors.textMuted,
                    fontSize: 17,
                  ),
                ),
                Text(_open ? '▲' : '▼', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ),
        if (_open)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 260),
            decoration: BoxDecoration(
              color: AppColors.panelRaised,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: kVehicleBrands.length,
              itemBuilder: (context, i) {
                final b = kVehicleBrands[i];
                return InkWell(
                  onTap: () {
                    widget.onChanged(b);
                    setState(() => _open = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: i == 0 ? null : const Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Text(b, style: const TextStyle(color: AppColors.text, fontSize: 17)),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
