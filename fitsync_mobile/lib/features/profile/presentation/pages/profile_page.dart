import 'package:flutter/material.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../payments/presentation/pages/my_payments_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/change_password_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import 'help_support_page.dart';
import '../../../../injection_container.dart' as di;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(l.profile,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFE8622A).withValues(alpha: 0.2),
                child: Text(
                  user?.firstName.isNotEmpty == true ? user!.firstName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Color(0xFFE8622A), fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8622A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(user?.role ?? 'Client',
                    style: const TextStyle(color: Color(0xFFE8622A), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 32),
              _InfoCard(children: [
                _InfoRow(icon: Icons.email, label: l.email, value: user?.email ?? '—'),
                const Divider(color: Colors.white12),
                _InfoRow(icon: Icons.phone, label: l.phone, value: user?.phoneNumber ?? l.notSet),
                const Divider(color: Colors.white12),
                _InfoRow(icon: Icons.location_on, label: l.address, value: user?.address ?? l.notSet),
              ]),
              const SizedBox(height: 20),
              _InfoCard(children: [
                _ActionRow(
                  icon: Icons.notifications,
                  label: l.notifications,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
                ),
                const Divider(color: Colors.white12),
                _ActionRow(
                  icon: Icons.receipt_long,
                  label: l.myPayments,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPaymentsPage())),
                ),
                const Divider(color: Colors.white12),
                _ActionRow(
                  icon: Icons.lock,
                  label: l.changePassword,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
                ),
                const Divider(color: Colors.white12),
                _ActionRow(
                  icon: Icons.language,
                  label: '${l.language}: ${localeProvider.locale.languageCode == 'bs' ? l.bosnian : l.english}',
                  onTap: () => _showLanguageDialog(context, l, localeProvider),
                ),
                const Divider(color: Colors.white12),
                _ActionRow(
                  icon: Icons.help_outline,
                  label: l.helpAndSupport,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage())),
                ),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(l.logout, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _confirmLogout(context, l),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l, LocaleProvider localeProvider) {
    final prefs = di.sl<SharedPreferences>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: Text(l.selectLanguage, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LangTile(
              label: l.bosnian,
              code: 'bs',
              current: localeProvider.locale.languageCode,
              onTap: () { localeProvider.setLocale(const Locale('bs'), prefs); Navigator.pop(context); },
            ),
            _LangTile(
              label: l.english,
              code: 'en',
              current: localeProvider.locale.languageCode,
              onTap: () { localeProvider.setLocale(const Locale('en'), prefs); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: Text(l.logout, style: const TextStyle(color: Colors.white)),
        content: Text(l.logoutConfirm, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { Navigator.pop(context); context.read<AuthProvider>().logout(); },
            child: Text(l.logout, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String label, code, current;
  final VoidCallback onTap;
  const _LangTile({required this.label, required this.code, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label, style: const TextStyle(color: Colors.white)),
    trailing: code == current ? const Icon(Icons.check, color: Color(0xFFE8622A)) : null,
    onTap: onTap,
  );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E2A3A),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(children: children),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF4A90D9), size: 20),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      ]),
    ]),
  );
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
        Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
      ]),
    ),
  );
}
