import 'package:flutter/material.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../injection_container.dart' as di;
import '../../../help/domain/entities/faq.dart';
import '../../../help/domain/entities/support_contact.dart';
import '../../../help/presentation/providers/help_provider.dart';

/// Help and support.
///
/// Everything on this screen used to be hardcoded: seven English questions in a
/// `static const` list, plus a support@fitsync.app address and a US phone number
/// that belonged to nobody. It is all administrator-owned content now, fetched
/// from the API and editable in the desktop app.
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => di.sl<HelpProvider>()..load(),
        child: const _HelpSupportView(),
      );
}

class _HelpSupportView extends StatelessWidget {
  const _HelpSupportView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF152030),
        foregroundColor: Colors.white,
        title: Text(l.helpAndSupport),
        elevation: 0,
      ),
      body: Consumer<HelpProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8622A)),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFE8622A),
            onRefresh: provider.load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            apiErrorText(context, provider.errorCode, provider.error),
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ]),
                    ),
                  ),
                if (provider.contact != null) _ContactCard(contact: provider.contact!),
                const SizedBox(height: 24),
                Text(
                  l.faqTitle,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (provider.faqs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      provider.error != null ? l.helpLoadFailed : l.helpNoFaqs,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...provider.faqs.map((faq) => _FaqTile(faq: faq)),
                const SizedBox(height: 24),
                const _AppInfoCard(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final SupportContact contact;

  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2A3A), Color(0xFF152030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8622A).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8622A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.support_agent, color: Color(0xFFE8622A), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.contactSupport,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(l.helpContactUs,
                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _ContactRow(
            icon: Icons.email_outlined,
            label: l.email,
            value: contact.email,
            onTap: () => _launch('mailto:${contact.email}'),
          ),
          const SizedBox(height: 10),
          _ContactRow(
            icon: Icons.phone_outlined,
            label: l.phone,
            value: contact.phoneNumber,
            onTap: () => _launch('tel:${contact.phoneNumber.replaceAll(' ', '')}'),
          ),
          const SizedBox(height: 10),
          _ContactRow(
            icon: Icons.access_time,
            label: l.workingHours,
            value: contact.workingHours,
          ),
          if (contact.address != null && contact.address!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ContactRow(
              icon: Icons.place_outlined,
              label: l.address,
              value: contact.address!,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _launch(String uri) async {
    final parsed = Uri.parse(uri);
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed);
    }
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Icon(icon, color: Colors.white54, size: 18),
            const SizedBox(width: 10),
            Text('$label:', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: onTap != null ? const Color(0xFFE8622A) : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ]),
        ),
      );
}

class _FaqTile extends StatelessWidget {
  final Faq faq;

  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            iconColor: const Color(0xFFE8622A),
            collapsedIconColor: Colors.white54,
            title: Text(
              faq.question,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    faq.answer,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        const Icon(Icons.fitness_center, color: Color(0xFFE8622A), size: 28),
        const SizedBox(height: 8),
        const Text('FitSync',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l.versionLabel,
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 4),
        Text(l.allRightsReserved,
            style: TextStyle(color: Colors.grey[600], fontSize: 11)),
      ]),
    );
  }
}
