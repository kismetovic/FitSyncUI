import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../reservations/domain/entities/reservation.dart';
import '../../../reservations/domain/entities/reservation_status.dart';
import '../../../reservations/presentation/providers/reservations_provider.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationsProvider>().loadReservations();
    });
  }

  Map<DateTime, List<Reservation>> _buildEventMap(List<Reservation> reservations) {
    final map = <DateTime, List<Reservation>>{};
    for (final r in reservations) {
      final key = DateTime(r.reservationDate.year, r.reservationDate.month, r.reservationDate.day);
      (map[key] ??= []).add(r);
    }
    return map;
  }

  List<Reservation> _eventsForDay(DateTime day, Map<DateTime, List<Reservation>> eventMap) {
    final key = DateTime(day.year, day.month, day.day);
    return eventMap[key] ?? [];
  }

  Color _statusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.approved:
        return const Color(0xFF27AE60);
      case ReservationStatus.paid:
        return const Color(0xFF16A085);
      case ReservationStatus.pendingApproval:
        return const Color(0xFFF39C12);
      case ReservationStatus.initial:
        return const Color(0xFF4A90D9);
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationsProvider>(
      builder: (context, provider, _) {
        final eventMap = _buildEventMap(provider.reservations);
        final selectedEvents = _selectedDay != null
            ? _eventsForDay(_selectedDay!, eventMap)
            : <Reservation>[];

        return Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context).myCalendar,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        onPressed: () => provider.loadReservations(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _LegendRow(),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2A3A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TableCalendar<Reservation>(
                    // Without this the header and weekday row stay English.
                    locale: Localizations.localeOf(context).languageCode,
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2027, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) => _eventsForDay(day, eventMap),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: const TextStyle(color: Colors.white70),
                      weekendTextStyle: const TextStyle(color: Color(0xFFE8622A)),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFFE8622A),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFFE8622A).withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFF27AE60),
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                      markerSize: 6,
                      markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                      cellMargin: const EdgeInsets.all(4),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFFE8622A)),
                      rightChevronIcon: const Icon(Icons.chevron_right, color: Color(0xFFE8622A)),
                      decoration: const BoxDecoration(
                        color: Color(0xFF152030),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white54, fontSize: 12),
                      weekendStyle: TextStyle(color: Color(0xFFE8622A), fontSize: 12),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return null;
                        return Positioned(
                          bottom: 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: events.take(3).map((r) {
                              return Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: _statusColor(r.status),
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      defaultBuilder: (context, day, _) {
                        final events = _eventsForDay(day, eventMap);
                        if (events.isEmpty) return null;
                        final dominantStatus = events.first.status;
                        final color = _statusColor(dominantStatus);
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: color.withValues(alpha: 0.5)),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    onPageChanged: (focused) {
                      setState(() => _focusedDay = focused);
                    },
                  ),
                ),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFE8622A))),
                  )
                else if (_selectedDay != null)
                  Expanded(
                    child: selectedEvents.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context).noReservationsOn(
                                  DateFormat('d MMMM', Localizations.localeOf(context).languageCode)
                                      .format(_selectedDay!)),
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: selectedEvents.length,
                            itemBuilder: (ctx, i) => _ReservationTile(
                              reservation: selectedEvents[i],
                              statusColor: _statusColor(selectedEvents[i].status),
                            ),
                          ),
                  )
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).upcomingReservations,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: provider.reservations.isEmpty
                                ? Center(
                                    child: Text(
                                      'No reservations yet.\nTap a day to see details.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: provider.reservations
                                        .where((r) => r.reservationDate.isAfter(DateTime.now()))
                                        .length,
                                    itemBuilder: (ctx, i) {
                                      final upcoming = provider.reservations
                                          .where((r) => r.reservationDate.isAfter(DateTime.now()))
                                          .toList();
                                      if (i >= upcoming.length) return null;
                                      return _ReservationTile(
                                        reservation: upcoming[i],
                                        statusColor: _statusColor(upcoming[i].status),
                                      );
                                    },
                                  ),
                          ),
                        ],
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
}

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      (const _LegendDot(color: Color(0xFF4A90D9)), l.statusInitial),
      (const _LegendDot(color: Color(0xFFF39C12)), l.legendPending),
      (const _LegendDot(color: Color(0xFF27AE60)), l.statusApproved),
      (const _LegendDot(color: Color(0xFF16A085)), l.statusPaid),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 14,
        children: items
            .map((e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    e.$1,
                    const SizedBox(width: 4),
                    Text(e.$2, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _ReservationTile extends StatelessWidget {
  final Reservation reservation;
  final Color statusColor;

  const _ReservationTile({required this.reservation, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    final l = AppLocalizations.of(context);
    final label = switch (reservation.status) {
      ReservationStatus.initial => l.statusInitial,
      ReservationStatus.approved => l.statusApproved,
      ReservationStatus.paid => l.statusPaid,
      ReservationStatus.cancelled => l.statusCancelled,
      ReservationStatus.completed => l.statusCompleted,
      ReservationStatus.pendingApproval => l.statusPendingApproval,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.trainingName ?? 'Training',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fmt.format(reservation.reservationDate),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              label,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
