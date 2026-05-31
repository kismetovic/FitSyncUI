import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';
import '../../domain/entities/reservation_type.dart';
import '../providers/reservations_provider.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationsProvider>().loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      const Text('My Reservations',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        onPressed: () => provider.loadReservations(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8622A)))
                      : provider.reservations.isEmpty
                          ? const _EmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: provider.reservations.length,
                              itemBuilder: (context, i) => _ReservationCard(
                                reservation: provider.reservations[i],
                                onCancel: (r) => _confirmCancel(context, provider, r),
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmCancel(BuildContext context, ReservationsProvider provider, Reservation r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: const Text('Cancel Reservation', style: TextStyle(color: Colors.white)),
        content: Text(
          'Cancel your reservation for "${r.trainingName ?? 'this training'}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep It')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await provider.cancel(r.id);
            },
            child: const Text('Cancel Reservation', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final void Function(Reservation) onCancel;

  const _ReservationCard({required this.reservation, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, MMM d • HH:mm');
    final statusColors = {
      ReservationStatus.initial: Colors.blue,
      ReservationStatus.pendingApproval: Colors.orange,
      ReservationStatus.approved: Colors.green,
      ReservationStatus.paid: Colors.teal,
      ReservationStatus.completed: Colors.purple,
      ReservationStatus.cancelled: Colors.red,
    };
    final statusColor = statusColors[reservation.status] ?? Colors.grey;
    final statusLabel = reservation.status.name[0].toUpperCase() + reservation.status.name.substring(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reservation.trainingName ?? 'Training',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[500], size: 14),
              const SizedBox(width: 6),
              Text(fmt.format(reservation.reservationDate),
                  style: TextStyle(color: Colors.grey[300], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.repeat, color: Colors.grey[500], size: 14),
              const SizedBox(width: 6),
              Text(
                reservation.reservationType == ReservationType.oneTime
                    ? 'One-time Session'
                    : 'Monthly Package',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          if (reservation.status != ReservationStatus.cancelled &&
              reservation.status != ReservationStatus.completed) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => onCancel(reservation),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.calendar_today, color: Colors.grey[700], size: 64),
      const SizedBox(height: 16),
      Text('No reservations yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
      const SizedBox(height: 8),
      Text('Book a training to get started', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    ]),
  );
}
