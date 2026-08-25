import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/error/api_error_messages.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/membership_package.dart';
import '../../domain/entities/user_membership.dart';
import '../providers/memberships_provider.dart';
import '../../../../core/utils/money.dart';

/// Review item 19: monthly reservations are a real feature, so the app needs a
/// place to buy a package and to see how many sessions are left on it. Without
/// this screen a user could pick "Monthly" when booking and had no way to ever
/// own a package.
class MembershipsPage extends StatefulWidget {
  const MembershipsPage({super.key});

  @override
  State<MembershipsPage> createState() => _MembershipsPageState();
}

class _MembershipsPageState extends State<MembershipsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipsProvider>().load();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Coming back from the browser is the signal that the user is done at PayPal,
  /// so the check starts by itself. The client is never asked to confirm that a
  /// payment succeeded - the server captures and verifies, exactly as it does for
  /// a booking.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    final provider = context.read<MembershipsProvider>();
    if (!provider.hasPendingPayPal) return;

    provider.verifyPayPal().then((paid) {
      if (!mounted || !paid) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).packagePaid),
      ));
    });
  }

  Future<void> _confirmAndBuy(MembershipPackage package) async {
    final l = AppLocalizations.of(context);
    final provider = context.read<MembershipsProvider>();
    final price = formatMoney(package.price);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: Text(l.buyPackage, style: const TextStyle(color: Colors.white)),
        content: Text(
          l.confirmPurchase(package.name, price),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l.cancel, style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l.buy, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final membership = await provider.purchase(package.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(membership != null
            ? l.packagePurchased
            : apiErrorText(context, provider.errorCode, provider.error)),
        backgroundColor: membership != null ? const Color(0xFF2E7D32) : Colors.red[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Consumer<MembershipsProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: const Color(0xFF0F1923),
        appBar: AppBar(
          backgroundColor: const Color(0xFF152030),
          foregroundColor: Colors.white,
          title: Text(l.monthlyPackages),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: provider.load,
            ),
          ],
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8622A)))
            : RefreshIndicator(
                onRefresh: provider.load,
                color: const Color(0xFFE8622A),
                backgroundColor: const Color(0xFF1E2A3A),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SectionTitle(text: l.myPackages),
                    const SizedBox(height: 10),
                    if (provider.myMemberships.isEmpty)
                      _EmptyOwned(text: l.noPackagesOwned)
                    else
                      ...provider.myMemberships.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _OwnedCard(membership: m, l: l, provider: provider),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _SectionTitle(text: l.monthlyPackages),
                    const SizedBox(height: 10),
                    ...provider.packages.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PackageCard(
                          package: p,
                          l: l,
                          isPurchasing: provider.purchasingPackageId == p.id,
                          blockedBy: _coveringPackageName(provider, p),
                          onBuy: () => _confirmAndBuy(p),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      );
}

class _EmptyOwned extends StatelessWidget {
  final String text;
  const _EmptyOwned({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.card_membership, color: Colors.white38, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 13))),
          ],
        ),
      );
}

class _OwnedCard extends StatelessWidget {
  final UserMembership membership;
  final AppLocalizations l;
  final MembershipsProvider provider;

  const _OwnedCard({
    required this.membership,
    required this.l,
    required this.provider,
  });

  /// The status badge used to print the raw Dart enum name, so a package waiting
  /// to be paid for read "PENDINGPAYMENT".
  String _statusLabel() {
    switch (membership.status) {
      case MembershipStatus.active:
        return l.active;
      case MembershipStatus.expired:
        return l.expired;
      case MembershipStatus.cancelled:
        return l.cancelled;
      case MembershipStatus.pendingPayment:
        return l.packageAwaitingPayment;
    }
  }

  Color _accentColour() {
    if (membership.status == MembershipStatus.pendingPayment) {
      return const Color(0xFFF39C12);
    }
    return membership.isUsable ? const Color(0xFF2E7D32) : Colors.white24;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final progress = membership.sessionsTotal == 0
        ? 0.0
        : membership.sessionsUsed / membership.sessionsTotal;
    final accent = _accentColour();
    final busy = provider.busyMembershipId == membership.id;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  membership.membershipPackageName ?? '',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel().toUpperCase(),
                  style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.sessionsLeft(membership.sessionsRemaining, membership.sessionsTotal),
            style: const TextStyle(
                color: Color(0xFFE8622A), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFE8622A)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.validUntil(dateFormat.format(membership.endDate)),
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          if (membership.awaitingPayment) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF39C12).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.hourglass_bottom, color: Color(0xFFF39C12), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.packageUnpaidNotice,
                      style: const TextStyle(color: Color(0xFFF39C12), fontSize: 11)),
                ),
              ]),
            ),
          ],
          if (busy) ...[
            const SizedBox(height: 10),
            const Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE8622A)),
              ),
            ),
          ] else if (membership.awaitingPayment || membership.canBeCancelled) ...[
            const SizedBox(height: 10),
            Row(children: [
              if (membership.awaitingPayment)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment, size: 16),
                    label: Text(l.payPackage, style: const TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8622A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => showPackagePaymentSheet(context, provider, membership),
                  ),
                ),
              if (membership.awaitingPayment && membership.canBeCancelled)
                const SizedBox(width: 8),
              if (membership.canBeCancelled)
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 16),
                    label: Text(l.cancelPackage, style: const TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[300],
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => confirmCancelPackage(context, provider, membership, l),
                  ),
                ),
            ]),
          ],
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final MembershipPackage package;
  final AppLocalizations l;
  final bool isPurchasing;
  final VoidCallback onBuy;

  /// Name of a package the client already holds that covers the same trainings.
  /// The server refuses the purchase either way; showing it here means the button
  /// never invites a tap that is going to fail.
  final String? blockedBy;

  const _PackageCard({
    required this.package,
    required this.l,
    required this.isPurchasing,
    this.blockedBy,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8622A).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  package.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Text(
                formatMoney(package.price),
                style: const TextStyle(
                    color: Color(0xFFE8622A), fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          if (package.description != null) ...[
            const SizedBox(height: 6),
            Text(
              package.description!,
              style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.3),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Tag(icon: Icons.event_available, text: '${package.sessionCount}'),
              _Tag(icon: Icons.schedule, text: l.packageDurationDays(package.durationDays)),
              _Tag(
                icon: Icons.sell_outlined,
                text: l.perSession(formatMoney(package.pricePerSession)),
              ),
              _Tag(
                icon: package.coversAllTypes ? Icons.all_inclusive : Icons.filter_alt_outlined,
                text: package.coversAllTypes
                    ? l.allTrainingTypes
                    : l.onlyTrainingType(package.trainingTypeName ?? ''),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (blockedBy != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, color: Colors.grey[400], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.alreadyCoveredBy(blockedBy!),
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ),
              ]),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8622A),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: (isPurchasing || blockedBy != null) ? null : onBuy,
              child: isPurchasing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      l.buyPackage,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1923),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white54),
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      );
}

/// The two ways to pay for a package, deliberately the same two a booking
/// offers. PayPal opens the official approval page in the browser; cash records
/// the intent and leaves the money to staff.
Future<void> showPackagePaymentSheet(
  BuildContext context,
  MembershipsProvider provider,
  UserMembership membership,
) async {
  final l = AppLocalizations.of(context);

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1E2A3A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l.choosePaymentMethod,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${membership.membershipPackageName ?? ''} · ${formatMoney(membership.pricePaid)}',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: Text(l.payWithPayPalShort),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D95CE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                Navigator.pop(sheetContext);
                final url = await provider.startPayPal(membership.id);
                if (url == null || !context.mounted) return;
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.store_outlined),
              label: Text(l.payWithCashShort),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                Navigator.pop(sheetContext);
                final ok = await provider.payWithCash(membership.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? l.cashSelectedPackage
                      : apiErrorText(context, provider.errorCode, provider.error)),
                ));
              },
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    ),
  );
}

/// Cancelling is refused by the server once a session has been spent, so the
/// dialog only ever appears for a package that can actually go.
Future<void> confirmCancelPackage(
  BuildContext context,
  MembershipsProvider provider,
  UserMembership membership,
  AppLocalizations l,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1E2A3A),
      title: Text(l.cancelPackageConfirm,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      content: Text(
        '${membership.membershipPackageName ?? ''} · ${formatMoney(membership.pricePaid)}',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l.goBack, style: TextStyle(color: Colors.grey[400])),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l.cancelPackage),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final ok = await provider.cancel(membership.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(ok
        ? l.packageCancelled
        : apiErrorText(context, provider.errorCode, provider.error)),
  ));
}

/// Name of a package the client already holds that covers the same trainings as
/// [candidate], or null if buying it is fine.
///
/// This mirrors the rule the server enforces in EnsureNoOverlappingPackageAsync. It
/// is a hint for the button state only - the server is still the authority, and a
/// purchase that slips through is refused with MEMBERSHIP_OVERLAP.
String? _coveringPackageName(MembershipsProvider provider, MembershipPackage candidate) {
  final now = DateTime.now();

  for (final held in provider.myMemberships) {
    // Exhausted, expired and cancelled packages do not block a renewal.
    final counts = held.awaitingPayment ||
        (held.status == MembershipStatus.active &&
            !held.endDate.isBefore(DateTime(now.year, now.month, now.day)) &&
            held.sessionsRemaining > 0);
    if (!counts) continue;

    // A package with no training type covers everything, so it overlaps anything.
    final coversSame = held.trainingTypeId == null ||
        candidate.trainingTypeId == null ||
        held.trainingTypeId == candidate.trainingTypeId;
    if (coversSame) return held.membershipPackageName ?? '';
  }
  return null;
}
