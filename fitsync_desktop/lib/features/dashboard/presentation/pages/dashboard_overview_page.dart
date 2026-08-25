import 'package:flutter/material.dart';
import '../../../../core/error/api_error_messages.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/utils/money.dart';

class DashboardOverviewPage extends StatefulWidget {
  const DashboardOverviewPage({super.key});

  @override
  State<DashboardOverviewPage> createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // /Dashboard/stats already carries TotalRevenue as a SUM over captured
      // payments, so the dashboard no longer loads the payment table to add it up.
      context.read<DashboardProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Consumer<DashboardProvider>(
      builder: (context, dashProvider, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.navDashboard,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(l.adminPanel, style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 32),
                if (dashProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (dashProvider.error != null)
                  _ErrorCard(
                      message: apiErrorText(context, dashProvider.errorCode, dashProvider.error),
                      onRetry: dashProvider.loadStats)
                else
                  _StatsGrid(
                    stats: dashProvider.stats,
                    totalRevenue: dashProvider.stats?.totalRevenue ?? 0,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final dynamic stats;
  final double totalRevenue;

  const _StatsGrid({this.stats, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cards = [
      (label: l.totalUsers, value: stats?.totalUsers?.toString() ?? '—',
          icon: Icons.people, color: const Color(0xFF4A90D9)),
      (label: l.totalTrainings, value: stats?.totalTrainings?.toString() ?? '—',
          icon: Icons.fitness_center, color: const Color(0xFFE8622A)),
      (label: l.totalReservations, value: stats?.totalReservations?.toString() ?? '—',
          icon: Icons.calendar_today, color: const Color(0xFF27AE60)),
      (label: l.totalRevenue, value: formatMoney(totalRevenue),
          icon: Icons.payments_outlined, color: const Color(0xFFF39C12)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: cards.map((c) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: c == cards.last ? 0 : 16),
              child: _StatCard(label: c.label, value: c.value, icon: c.icon, color: c.color),
            ),
          )).toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
          TextButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).retry)),
        ],
      ),
    );
  }
}
