import 'dart:async';
import '../../../../core/error/api_error_messages.dart';
import 'package:flutter/material.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/admin_payment.dart';
import '../providers/payments_provider.dart';
import '../../../../core/pagination/pagination_bar.dart';
import '../../../../core/utils/money.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  /// The filter is applied in SQL now, so keystrokes are debounced.
  Timer? _searchDebounce;

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) context.read<AdminPaymentsProvider>().search(value.trim());
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPaymentsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Consumer<AdminPaymentsProvider>(
      builder: (context, provider, _) {
        // Filtering happens server-side; this list holds one page.
        final filtered = provider.payments;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(l.navPayments,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    onPressed: provider.load,
                    tooltip: l.refresh,
                  ),
                ]),
                const SizedBox(height: 16),

                if (!provider.isLoading && provider.error == null)
                  _SummaryRow(provider: provider, l: l),
                const SizedBox(height: 20),

                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l.searchPayments,
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    filled: true,
                    fillColor: const Color(0xFF1E2A3A),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 20),

                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(apiErrorText(context, provider.errorCode, provider.error), style: const TextStyle(color: Colors.red)),
                  ),

                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? _EmptyState(l: l)
                          : _PaymentsTable(payments: filtered, l: l),
                ),
                PaginationBar(
                  page: provider.page,
                  pageSize: provider.pageSize,
                  totalCount: provider.totalCount,
                  isLoading: provider.isLoading,
                  onPageChanged: (p) => provider.load(page: p),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final AdminPaymentsProvider provider;
  final AppLocalizations l;
  const _SummaryRow({required this.provider, required this.l});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _SummaryCard(
        label: l.totalRevenue,
        value: formatMoney(provider.totalRevenue),
        icon: Icons.payments_outlined,
        color: const Color(0xFF27AE60),
      )),
      const SizedBox(width: 16),
      Expanded(child: _SummaryCard(
        label: 'PayPal',
        value: '${provider.paypalCount}',
        icon: Icons.account_balance_wallet,
        color: const Color(0xFF3D95CE),
      )),
      const SizedBox(width: 16),
      Expanded(child: _SummaryCard(
        label: l.cash,
        value: '${provider.cashCount}',
        icon: Icons.store,
        color: const Color(0xFF4A90D9),
      )),
      const SizedBox(width: 16),
      Expanded(child: _SummaryCard(
        label: l.totalTransactions,
        // Every payment, not the handful this page happens to show.
        value: '${provider.totalCount}',
        icon: Icons.receipt_long,
        color: const Color(0xFFE8622A),
      )),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1E2A3A),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ])),
    ]),
  );
}

class _PaymentsTable extends StatelessWidget {
  final List<AdminPayment> payments;
  final AppLocalizations l;
  const _PaymentsTable({required this.payments, required this.l});

  static const _p = EdgeInsets.symmetric(horizontal: 12, vertical: 12);
  Widget _h(String t) => Padding(padding: _p,
      child: Text(t, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)));
  Widget _d(Widget w) => Padding(padding: _p, child: w);

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Container(
          decoration: const BoxDecoration(color: Color(0xFF152030),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            Expanded(flex: 2, child: _h(l.date)),
            Expanded(flex: 2, child: _h(l.client)),
            Expanded(flex: 2, child: _h(l.training)),
            Expanded(flex: 1, child: _h(l.amount)),
            Expanded(flex: 1, child: _h(l.provider)),
            Expanded(flex: 2, child: _h(l.transactionId)),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: payments.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
            itemBuilder: (ctx, i) {
              final p = payments[i];
              final isPayPal = p.paymentProvider == 0;
              return InkWell(
                hoverColor: const Color(0xFF243347),
                child: Row(children: [
                  Expanded(flex: 2, child: _d(Text(fmt.format(p.createdAt),
                      style: const TextStyle(color: Colors.white70, fontSize: 13)))),
                  Expanded(flex: 2, child: _d(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(p.userName ?? '—', style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
                      if (p.userEmail != null)
                        Text(p.userEmail!, style: TextStyle(color: Colors.grey[500], fontSize: 11), overflow: TextOverflow.ellipsis),
                    ],
                  ))),
                  Expanded(flex: 2, child: _d(Text(p.trainingName ?? p.membershipPackageName ?? '—',
                      style: const TextStyle(color: Colors.white70), overflow: TextOverflow.ellipsis))),
                  Expanded(flex: 1, child: _d(Text(
                    formatMoney(p.amount),
                    style: const TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold),
                  ))),
                  Expanded(flex: 1, child: _d(_ProviderBadge(isPayPal))),
                  Expanded(flex: 2, child: _d(Text(
                    p.transactionId.length > 16
                        ? '${p.transactionId.substring(0, 16)}…'
                        : p.transactionId,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12, fontFamily: 'monospace'),
                  ))),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _ProviderBadge extends StatelessWidget {
  final bool isPayPal;
  const _ProviderBadge(this.isPayPal);

  @override
  Widget build(BuildContext context) {
    final color = isPayPal ? const Color(0xFF3D95CE) : const Color(0xFF4A90D9);
    final label = isPayPal ? 'PayPal' : 'Gotovina';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyState({required this.l});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.receipt_long, size: 64, color: Colors.grey[700]),
      const SizedBox(height: 16),
      Text(l.noPaymentsFound, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
    ]),
  );
}
