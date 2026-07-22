import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_info.dart';
import '../services/device_id_service.dart';
import '../services/dtc_repository.dart';
import '../theme/colors.dart';

/// About/Settings screen — app version, support contact, Privacy Policy
/// link (required by Google Play, not just on the store listing page), and
/// a share-the-app action. Pushed via Navigator since it's a standalone
/// info screen with no interaction with the app's main state machine.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri(scheme: 'mailto', path: AppInfo.supportEmail);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('راسلنا على: ${AppInfo.supportEmail}')),
      );
    }
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(AppInfo.privacyPolicyUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الرابط')),
      );
    }
  }

  Future<void> _shareApp() async {
    await SharePlus.instance.share(ShareParams(
      text: 'تطبيق أكواد الأعطال — دليلك السريع لفهم أكواد أعطال السيارة\n'
          'حمّل التطبيق: ${AppInfo.playStoreUrl}',
    ));
  }

  /// Self-service data deletion (PDPL right to deletion) — a real working
  /// mechanism, not just a promise handled manually over email.
  Future<void> _confirmAndDeleteData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.panelRaised,
        title: const Text('حذف بياناتي', style: TextStyle(color: AppColors.text)),
        content: const Text(
          'سيتم حذف سجل بحثك وحالة استخدامك اليومي نهائياً من خوادمنا. لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('حذف', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final deviceId = await DeviceIdService.getDeviceId();
    final success = await DtcRepository().deleteMyData(deviceId);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'تم حذف بياناتك بنجاح' : 'حدث خطأ، حاول مرة أخرى')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_forward, color: AppColors.text),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'الإعدادات',
                    style: TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'إصدار التطبيق',
                subtitle: AppInfo.version,
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.email_outlined,
                title: 'تواصل معنا',
                subtitle: AppInfo.supportEmail,
                onTap: () => _openEmail(context),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'سياسة الخصوصية وشروط الاستخدام',
                onTap: () => _openPrivacyPolicy(context),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.share_outlined,
                title: 'شارك التطبيق',
                onTap: _shareApp,
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.delete_outline,
                iconColor: AppColors.red,
                title: 'حذف بياناتي',
                onTap: () => _confirmAndDeleteData(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, this.iconColor, required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.panelRaised,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.amber, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.text, fontSize: 16)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
