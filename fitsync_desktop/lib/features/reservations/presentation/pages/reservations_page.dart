import 'package:flutter/material.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';
import '../providers/reservations_provider.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});
  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationsProvider>().loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<ReservationsProvider>(
      builder: (context, provider, _) {
        final filtered = provider.reservations.where((r) {
          final q = _searchQuery.toLowerCase();
          return q.isEmpty ||
              (r.userName?.toLowerCase().contains(q) ?? false) ||
              (r.trainingName?.toLowerCase().contains(q) ?? false);
        }).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(l.reservations, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    onPressed: () => provider.loadReservations(),
                    tooltip: l.refresh,
                  ),
                ]),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l.searchReservations,
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    filled: true,
                    fillColor: const Color(0xFF1E2A3A),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 20),
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
                  ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? _EmptyState(l: l)
                          : _ReservationsTable(
                              reservations: filtered, l: l,
                              onApprove: (r) => provider.approve(r.id),
                              onCancel: (r) => provider.updateStatus(r.id, ReservationStatus.cancelled),
                              onDelete: (r) => _confirmDelete(context, provider, r, l),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ReservationsProvider provider, Reservation r, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: Text(l.deleteReservation, style: const TextStyle(color: Colors.white)),
        content: Text('${l.delete} "${r.trainingName}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async { Navigator.pop(context); await provider.remove(r.id); },
            child: Text(l.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ReservationsTable extends StatelessWidget {
  final List<Reservation> reservations;
  final AppLocalizations l;
  final void Function(Reservation) onApprove;
  final void Function(Reservation) onCancel;
  final void Function(Reservation) onDelete;

  const _ReservationsTable({
    required this.reservations, required this.l,
    required this.onApprove, required this.onCancel, required this.onDelete,
  });

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
            Expanded(flex: 2, child: _h(l.client)),
            Expanded(flex: 2, child: _h(l.training)),
            Expanded(flex: 2, child: _h(l.date)),
            Expanded(flex: 1, child: _h(l.type)),
            Expanded(flex: 2, child: _h(l.status)),
            Expanded(flex: 2, child: _h(l.actions)),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: reservations.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
            itemBuilder: (ctx, i) {
              final r = reservations[i];
              return InkWell(
                hoverColor: const Color(0xFF243347),
                child: Row(children: [
                  Expanded(flex: 2, child: _d(Text(r.userName ?? 'u2014',
                      style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis))),
                  Expanded(flex: 2, child: _d(Text(r.trainingName ?? 'u2014',
                      style: const TextStyle(color: Colors.white70), overflow: TextOverflow.ellipsis))),
                  Expanded(flex: 2, child: _d(Text(fmt.format(r.reservationDate),
                      style: const TextStyle(color: Colors.white70)))),
                  Expanded(flex: 1, child: _d(Text(r.reservationType.name,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)))),
                  Expanded(flex: 2, child: _d(_StatusBadge(r.status, l))),
                  Expanded(flex: 2, child: _d(Row(mainAxisSize: MainAxisSize.min, children: [
                    if (r.status == ReservationStatus.initial || r.status == ReservationStatus.pendingApproval)
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        onPressed: () => onApprove(r),
                        tooltip: l.approve,
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                    if (r.status != ReservationStatus.cancelled) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.orange, size: 20),
                        onPressed: () => onCancel(r),
                        tooltip: l.cancel,
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                    ],
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => onDelete(r),
                      tooltip: l.delete,
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                  ]))),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;
  final AppLocalizations l;
  const _StatusBadge(this.status, this.l);

  @override
  Widget build(BuildContext context) {
    final colors = {
      ReservationStatus.initial: Colors.blue,
      ReservationStatus.pendingApproval: Colors.orange,
      ReservationStatus.approved: Colors.green,
      ReservationStatus.paid: Colors.teal,
      ReservationStatus.completed: Colors.purple,
      ReservationStatus.cancelled: Colors.red,
    };
    final labels = {
      ReservationStatus.initial: l.statusInitial,
      ReservationStatus.pendingApproval: l.statusPendingApproval,
      ReservationStatus.approved: l.statusApproved,
      ReservationStatus.paid: l.statusPaid,
      ReservationStatus.completed: l.statusCompleted,
      ReservationStatus.cancelled: l.statusCancelled,
    };
    final color = colors[status] ?? Colors.grey;
    final label = labels[status] ?? status.name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyState({required this.l});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.calendar_today, size: 64, color: Colors.grey[700]),
      const SizedBox(height: 16),
      Text(l.noReservationsFound, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
    ]),
  );
}
