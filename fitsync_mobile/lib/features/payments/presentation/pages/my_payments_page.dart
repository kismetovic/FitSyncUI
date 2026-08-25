import 'package:flutter/material.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment.dart';
import '../providers/payments_provider.dart';
import '../../../../core/utils/money.dart';

class MyPaymentsPage extends StatefulWidget {
  const MyPaymentsPage({super.key});

  @override
  State<MyPaymentsPage> createState() => _MyPaymentsPageState();
}

class _MyPaymentsPageState extends State<MyPaymentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentsProvider>().loadMyPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Consumer<PaymentsProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: const Color(0xFF0F1923),
        appBar: AppBar(
          backgroundColor: const Color(0xFF152030),
          foregroundColor: Colors.white,
          title: Text(l.myPayments),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: provider.loadMyPayments,
            ),
          ],
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8622A)))
            : provider.myPayments.isEmpty
                ? _EmptyState(l: l)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.myPayments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _PaymentCard(payment: provider.myPayments[i]),
                  ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    final isPayPal = payment.paymentProvider == PaymentProvider.paypal;
    final providerColor = isPayPal ? const Color(0xFF3D95CE) : const Color(0xFF4A90D9);
    final l = AppLocalizations.of(context);
    final providerLabel = isPayPal ? 'PayPal' : l.cash;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: providerColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPayPal ? Icons.account_balance_wallet : Icons.store,
              color: providerColor, size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      formatMoney(payment.amount),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _Badge(label: providerLabel, color: providerColor),
                ]),
                const SizedBox(height: 4),
                Text(fmt.format(payment.createdAt),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  payment.subject.isNotEmpty
                      ? payment.subject
                      : (payment.userMembershipId != null
                          ? l.monthlyPackage
                          : '${l.reservation} #${payment.reservationId ?? '-'}'),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyState({required this.l});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.receipt_long, size: 64, color: Colors.grey[700]),
      const SizedBox(height: 16),
      Text(l.noMyPayments, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
    ]),
  );
}
