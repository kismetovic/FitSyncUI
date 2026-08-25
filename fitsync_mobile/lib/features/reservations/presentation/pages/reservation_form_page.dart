import 'package:flutter/material.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../features/trainings/domain/entities/training.dart';
import '../../../additional_services/domain/entities/additional_service.dart';
import '../../../additional_services/presentation/providers/additional_services_provider.dart';
import '../../domain/entities/reservation_type.dart';
import '../../../memberships/domain/entities/user_membership.dart';
import '../../../memberships/presentation/pages/memberships_page.dart';
import '../../../memberships/presentation/providers/memberships_provider.dart';
import '../../domain/entities/slot_availability.dart';
import '../providers/reservations_provider.dart';
import 'reservation_confirm_page.dart';
import '../../../../core/utils/money.dart';

class ReservationFormPage extends StatefulWidget {
  final Training training;
  const ReservationFormPage({super.key, required this.training});

  @override
  State<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  ReservationType _reservationType = ReservationType.oneTime;
  bool _requestOutsideAvailability = false;
  bool _hasConflict = false;
  /// Free places per day, straight from the backend availability endpoint.
  /// Capacity itself is enforced server-side; this only greys out full days.
  Map<DateTime, SlotAvailability> _availability = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdditionalServicesProvider>().loadServices();
      // Needed to tell the user whether a monthly booking is possible at all.
      context.read<MembershipsProvider>().loadMine();
      _loadAvailability();
    });
  }

  Future<void> _loadAvailability() async {
    final availability = await context
        .read<ReservationsProvider>()
        .getTrainingAvailability(widget.training.id);
    if (mounted) setState(() => _availability = availability);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final combined = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );
    final fmt = DateFormat('EEEE, d. MMMM y.', Localizations.localeOf(context).languageCode);
    final timeFmt = DateFormat('HH:mm');

    return Consumer<AdditionalServicesProvider>(
      builder: (context, servicesProvider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          appBar: AppBar(
            backgroundColor: const Color(0xFF152030),
            foregroundColor: Colors.white,
            title: Text(l.bookTraining),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(l.training),
                const SizedBox(height: 10),
                _TrainingCard(training: widget.training),
                SizedBox(height: 24),

                _SectionHeader(l.selectDate),
                const SizedBox(height: 10),
                _PickerTile(icon: Icons.calendar_today, label: fmt.format(_selectedDate), onTap: _pickDate),
                const SizedBox(height: 12),
                _PickerTile(icon: Icons.access_time, label: timeFmt.format(combined), onTap: _pickTime),
                const SizedBox(height: 16),

                if (_availability.isNotEmpty)
                  _AvailabilityStrip(
                    bookingCounts: {
                      for (final entry in _availability.entries) entry.key: entry.value.bookedCount,
                    },
                    maxCapacity: widget.training.maxCapacity,
                    selectedDate: _selectedDate,
                    onDayTap: (day) => setState(() => _selectedDate = day),
                  ),
                SizedBox(height: 16),

                _SectionHeader(l.reservationType),
                const SizedBox(height: 10),
                ...ReservationType.values.map((type) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TypeOption(
                    type: type, selected: _reservationType, l: l,
                    onTap: () => setState(() => _reservationType = type),
                  ),
                )),

                // Review item 19: a monthly booking is paid out of a package, so
                // say up front whether the user has one that covers this training.
                if (_reservationType == ReservationType.monthly)
                  _MonthlyPackageBanner(
                    membership: context
                        .watch<MembershipsProvider>()
                        .usableFor(widget.training.trainingTypeId),
                    l: l,
                    onBuy: () async {
                      // Grab the provider before awaiting so nothing reaches for
                      // a BuildContext once the shop screen has been popped.
                      final memberships = context.read<MembershipsProvider>();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MembershipsPage()),
                      );
                      await memberships.loadMine();
                    },
                  ),
                const SizedBox(height: 8),

                if (_hasConflict) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: Row(children: [
                      Icon(Icons.warning_amber, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Expanded(child: Text(l.timeConflict,
                          style: const TextStyle(color: Colors.red, fontSize: 13))),
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _requestOutsideAvailability
                        ? const Color(0xFFF39C12).withValues(alpha: 0.08)
                        : const Color(0xFF1E2A3A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _requestOutsideAvailability
                          ? const Color(0xFFF39C12).withValues(alpha: 0.5)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(children: [
                    Icon(Icons.schedule, color: Color(0xFFF39C12), size: 20),
                    SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.requestOutsideAvailability,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(l.outsideAvailabilityHint,
                          style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ])),
                    Switch(
                      value: _requestOutsideAvailability,
                      onChanged: (v) => setState(() => _requestOutsideAvailability = v),
                      activeColor: const Color(0xFFF39C12),
                    ),
                  ]),
                ),
                SizedBox(height: 24),

                _SectionHeader(l.additionalServices),
                SizedBox(height: 4),
                Text(l.enhanceExperience, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 12),
                if (servicesProvider.isLoading)
                  Center(child: CircularProgressIndicator(color: Color(0xFFE8622A)))
                else if (servicesProvider.services.isEmpty)
                  Text(l.noAdditionalServices, style: TextStyle(color: Colors.grey[600], fontSize: 13))
                else
                  ...servicesProvider.services.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ServiceTile(
                      service: s,
                      isSelected: servicesProvider.selectedIds.contains(s.id),
                      onToggle: () => servicesProvider.toggleService(s.id),
                    ),
                  )),

                if (servicesProvider.selectedIds.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2A3A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(children: [
                      const Icon(Icons.add_circle, color: Color(0xFF4A90D9), size: 18),
                      const SizedBox(width: 8),
                      Text('${servicesProvider.selectedIds.length} service(s) added',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const Spacer(),
                      Text(formatMoneyDelta(servicesProvider.selectedTotal),
                          style: const TextStyle(color: Color(0xFF4A90D9), fontWeight: FontWeight.bold, fontSize: 14)),
                    ]),
                  ),
                ],

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8622A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      setState(() => _hasConflict = false);
                      // A refusal from the previous attempt (a time conflict, say)
                      // would otherwise still be on screen after the user goes back
                      // and picks a different slot.
                      context.read<ReservationsProvider>().clearError();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReservationConfirmPage(
                            training: widget.training,
                            reservationDate: combined,
                            reservationType: _reservationType,
                            additionalServiceIds: servicesProvider.selectedIds.toList(),
                            selectedServices: servicesProvider.selectedServices,
                            requestOutsideAvailability: _requestOutsideAvailability,
                            userMembershipId: _reservationType == ReservationType.monthly
                                ? context
                                    .read<MembershipsProvider>()
                                    .usableFor(widget.training.trainingTypeId)
                                    ?.id
                                : null,
                            onTimeConflict: () => setState(() => _hasConflict = true),
                          ),
                        ),
                      );
                    },
                    child: Text(l.continueButton,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFFE8622A))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFFE8622A))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }
}

class _TrainingCard extends StatelessWidget {
  final Training training;
  const _TrainingCard({required this.training});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8622A).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.fitness_center, color: Color(0xFFE8622A), size: 24),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(training.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(AppLocalizations.of(context).perSession(formatMoney(training.price)),
            style: const TextStyle(color: Color(0xFFE8622A), fontSize: 13)),
      ])),
    ]),
  );
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF4A90D9)),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
        const Spacer(),
        const Icon(Icons.chevron_right, color: Colors.white38),
      ]),
    ),
  );
}

class _TypeOption extends StatelessWidget {
  final ReservationType type, selected;
  final AppLocalizations l;
  final VoidCallback onTap;
  const _TypeOption({required this.type, required this.selected, required this.l, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = type == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8622A).withValues(alpha: 0.1) : const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFE8622A) : Colors.white12),
        ),
        child: Row(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? const Color(0xFFE8622A) : Colors.grey, width: 2),
            ),
            child: isSelected ? Center(child: Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE8622A)),
            )) : null,
          ),
          SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(type == ReservationType.oneTime ? l.oneTimeSession : l.monthlyPackage,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text(type == ReservationType.oneTime ? l.singleSession : l.recurringMonthly,
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ]),
        ]),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final AdditionalService service;
  final bool isSelected;
  final VoidCallback onToggle;
  const _ServiceTile({required this.service, required this.isSelected, required this.onToggle});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onToggle,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4A90D9).withValues(alpha: 0.1) : const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? const Color(0xFF4A90D9) : Colors.white12),
      ),
      child: Row(children: [
        Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected ? const Color(0xFF4A90D9) : Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(service.name, style: const TextStyle(color: Colors.white, fontSize: 14))),
        Text(formatMoneyDelta(service.price),
            style: TextStyle(
              color: isSelected ? const Color(0xFF4A90D9) : Colors.grey[400],
              fontWeight: FontWeight.w600, fontSize: 13,
            )),
      ]),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
}

class _AvailabilityStrip extends StatelessWidget {
  final Map<DateTime, int> bookingCounts;
  final int maxCapacity;
  final DateTime selectedDate;
  final void Function(DateTime) onDayTap;

  const _AvailabilityStrip({
    required this.bookingCounts,
    required this.maxCapacity,
    required this.selectedDate,
    required this.onDayTap,
  });

  Color _colorFor(int count) {
    if (count >= maxCapacity) return Colors.red;
    if (count >= maxCapacity * 0.7) return const Color(0xFFF39C12);
    return const Color(0xFF27AE60);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final days = bookingCounts.keys.toList()..sort();
    final dayFmt = DateFormat('E', locale);
    final dateFmt = DateFormat('d', locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(l.availability,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          _Dot(color: const Color(0xFF27AE60), label: l.slotFree),
          const SizedBox(width: 8),
          _Dot(color: const Color(0xFFF39C12), label: l.slotLimited),
          const SizedBox(width: 8),
          _Dot(color: Colors.red, label: l.slotFull),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final day = days[i];
              final count = bookingCounts[day] ?? 0;
              final color = _colorFor(count);
              final isSelected = isSameDay(day, selectedDate);

              return GestureDetector(
                onTap: () => onDayTap(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.25) : color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : color.withValues(alpha: 0.4),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dayFmt.format(day),
                          style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(dateFmt.format(day),
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Container(width: 8, height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
    ],
  );
}

/// Tells the user, before they reach the confirmation screen, whether a monthly
/// booking can actually go through. Without this the form happily offered
/// "Monthly" to someone with no package and the request failed at the API with
/// NO_USABLE_MEMBERSHIP.
class _MonthlyPackageBanner extends StatelessWidget {
  final UserMembership? membership;
  final AppLocalizations l;
  final VoidCallback onBuy;

  const _MonthlyPackageBanner({
    required this.membership,
    required this.l,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final has = membership != null;
    final accent = has ? const Color(0xFF2E7D32) : const Color(0xFFF39C12);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(has ? Icons.card_membership : Icons.info_outline, color: accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (has) ...[
                  Text(
                    membership!.membershipPackageName ?? '',
                    style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(height: 2),
                  Text(
                    l.sessionsLeft(membership!.sessionsRemaining, membership!.sessionsTotal),
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    l.coveredByPackage,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ] else ...[
                  Text(
                    l.needPackageForMonthly,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onBuy,
                    child: Text(
                      l.buyPackage,
                      style: TextStyle(
                        color: accent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
