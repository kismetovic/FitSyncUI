import 'package:flutter/material.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../features/trainings/domain/entities/training.dart';
import '../../../additional_services/domain/entities/additional_service.dart';
import '../../domain/entities/reservation_type.dart';
import '../providers/reservations_provider.dart';
import 'reservation_payment_page.dart';

class ReservationConfirmPage extends StatelessWidget {
  final Training training;
  final DateTime reservationDate;
  final ReservationType reservationType;
  final List<int> additionalServiceIds;
  final List<AdditionalService> selectedServices;
  final bool requestOutsideAvailability;
  final VoidCallback? onTimeConflict;

  const ReservationConfirmPage({
    super.key,
    required this.training,
    required this.reservationDate,
    required this.reservationType,
    this.additionalServiceIds = const [],
    this.selectedServices = const [],
    this.requestOutsideAvailability = false,
    this.onTimeConflict,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fmt = DateFormat('EEEE, MMM d, yyyy – HH:mm');
    final provider = context.watch<ReservationsProvider>();
    final servicesTotal = selectedServices.fold(0.0, (sum, s) => sum + s.price);
    final totalPrice = training.price + servicesTotal;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF152030),
        foregroundColor: Colors.white,
        title: Text(l.confirmReservation),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.reviewBooking,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l.confirmDetails, style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 24),

            if (requestOutsideAvailability) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF39C12).withValues(alpha: 0.4)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: Color(0xFFF39C12), size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.pendingTrainerApproval,
                        style: const TextStyle(color: Color(0xFFF39C12), fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(l.outsideHoursWarning,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ])),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A3A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(children: [
                _Row(icon: Icons.fitness_center, label: l.training, value: training.name),
                const Divider(color: Colors.white12, height: 24),
                _Row(icon: Icons.calendar_today, label: l.dateAndTime, value: fmt.format(reservationDate)),
                const Divider(color: Colors.white12, height: 24),
                _Row(
                  icon: Icons.repeat,
                  label: l.type,
                  value: reservationType == ReservationType.oneTime ? l.oneTimeSession : l.monthlyPackage,
                ),
                const Divider(color: Colors.white12, height: 24),
                _Row(icon: Icons.attach_money, label: l.basePrice,
                    value: '\$${training.price.toStringAsFixed(2)}'),
                if (selectedServices.isNotEmpty) ...[
                  const Divider(color: Colors.white12, height: 24),
                  _Row(icon: Icons.add_circle_outline, label: l.additionalServices, value: ''),
                  ...selectedServices.map((s) => Padding(
                    padding: const EdgeInsets.only(left: 32, top: 6),
                    child: Row(children: [
                      const Icon(Icons.check, color: Color(0xFF4A90D9), size: 14),
                      const SizedBox(width: 6),
                      Expanded(child: Text(s.name,
                          style: TextStyle(color: Colors.grey[300], fontSize: 13))),
                      Text('+\$${s.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFF4A90D9), fontSize: 13)),
                    ]),
                  )),
                ],
                const Divider(color: Colors.white12, height: 24),
                _Row(icon: Icons.receipt_long, label: l.total,
                    value: '\$${totalPrice.toStringAsFixed(2)}',
                    valueColor: const Color(0xFFE8622A)),
              ]),
            ),

            const SizedBox(height: 24),

            if (provider.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8622A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: provider.isLoading ? null : () => _confirm(context),
                child: provider.isLoading
                    ? const SizedBox(width: 24, height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(l.confirmAndContinue,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.goBack, style: TextStyle(color: Colors.grey[400])),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final provider = context.read<ReservationsProvider>();
    final reservation = await provider.book(
      trainingId: training.id,
      reservationDate: reservationDate,
      reservationType: reservationType,
      additionalServiceIds: additionalServiceIds,
      requestOutsideAvailability: requestOutsideAvailability,
    );

    if (!context.mounted) return;

    if (provider.error != null && provider.error!.contains('TIME_CONFLICT')) {
      onTimeConflict?.call();
      if (context.mounted) Navigator.pop(context);
      return;
    }

    if (reservation != null && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReservationPaymentPage(
            training: training,
            reservationId: reservation.id,
            totalAmount: training.price + selectedServices.fold(0.0, (sum, s) => sum + s.price),
          ),
        ),
      );
    }
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  const _Row({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: const Color(0xFF4A90D9), size: 20),
    const SizedBox(width: 12),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      if (value.isNotEmpty)
        Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.w600)),
    ]),
  ]);
}
