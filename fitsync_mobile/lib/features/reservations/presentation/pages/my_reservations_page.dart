import 'package:flutter/material.dart';
import '../../../../../core/error/api_error_messages.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';
import '../../domain/entities/reservation_type.dart';
import '../providers/reservations_provider.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';

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
                      Text(AppLocalizations.of(context).myReservations,
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

  /// Cancelling requires a reason, which is stored on the reservation together with
  /// who cancelled it and when. The reservation stays in the list as cancelled rather
  /// than disappearing, so the history remains complete.
  void _confirmCancel(BuildContext context, ReservationsProvider provider, Reservation r) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: const Text('Otkazivanje rezervacije', style: TextStyle(color: Colors.white)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Otkazujete rezervaciju za "${r.trainingName ?? 'ovaj trening'}".',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: reasonController,
                maxLines: 2,
                maxLength: 500,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Razlog otkazivanja',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  counterStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF243347),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 3) return 'Unesite razlog (najmanje 3 znaka).';
                  return null;
                },
              ),
              const SizedBox(height: 4),
              Text(
                'Trener će biti obaviješten o otkazivanju.',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final reason = reasonController.text.trim();
              Navigator.pop(dialogContext);

              final ok = await provider.cancel(r.id, reason);
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'Rezervacija je otkazana.'
                    : apiErrorText(context, provider.errorCode, provider.error)),
                backgroundColor: ok ? const Color(0xFF27AE60) : Colors.red,
              ));
            },
            child: const Text('Otkaži rezervaciju', style: TextStyle(color: Colors.white)),
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
    // Without a locale this prints English day and month names.
    final fmt = DateFormat('EEE, d MMM • HH:mm', Localizations.localeOf(context).languageCode);
    final statusColors = {
      ReservationStatus.initial: Colors.blue,
      ReservationStatus.pendingApproval: Colors.orange,
      ReservationStatus.approved: Colors.green,
      ReservationStatus.paid: Colors.teal,
      ReservationStatus.completed: Colors.purple,
      ReservationStatus.cancelled: Colors.red,
    };
    final statusColor = statusColors[reservation.status] ?? Colors.grey;
    final l = AppLocalizations.of(context);
    // The badge used to print the Dart enum name ("PendingApproval"), which
    // is neither Bosnian nor something a user should ever see.
    final statusLabel = switch (reservation.status) {
      ReservationStatus.initial => l.statusInitial,
      ReservationStatus.approved => l.statusApproved,
      ReservationStatus.paid => l.statusPaid,
      ReservationStatus.cancelled => l.statusCancelled,
      ReservationStatus.completed => l.statusCompleted,
      ReservationStatus.pendingApproval => l.statusPendingApproval,
    };

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
                    ? l.oneTimeSession
                    : l.monthlyPackage,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          if (reservation.status != ReservationStatus.cancelled &&
              reservation.status != ReservationStatus.completed) ...[
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                icon: Icon(Icons.cancel, size: 16),
                label: Text(AppLocalizations.of(context).cancel),
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
      SizedBox(height: 16),
      Text(AppLocalizations.of(context).noReservations, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
      SizedBox(height: 8),
      Text(AppLocalizations.of(context).bookTrainingToStart, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    ]),
  );
}
