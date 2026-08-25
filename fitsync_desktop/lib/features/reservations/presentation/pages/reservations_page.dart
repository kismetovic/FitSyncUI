import 'dart:async';
import '../../../../core/error/api_error_messages.dart';
import 'package:flutter/material.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';
import '../../../additional_services/presentation/providers/additional_services_provider.dart';
import '../providers/reservations_provider.dart';
import '../../../../core/pagination/pagination_bar.dart';
import '../../../../core/utils/money.dart';

/// Administrative reservation list.
///
/// Actions follow the backend state machine: approve, record a cash payment, mark
/// completed, or cancel with a reason. There is deliberately no delete action -
/// a cancelled reservation stays on record with its audit trail.
class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  /// The search now goes to the server, so keystrokes are debounced instead of
  /// firing a request per character.
  Timer? _searchDebounce;

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) context.read<ReservationsProvider>().search(value.trim());
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
      context.read<ReservationsProvider>().loadReservations();
      // The reservation response carries additional-service ids; the catalogue
      // turns them into names for the list.
      context.read<AdditionalServicesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Consumer<ReservationsProvider>(
      builder: (context, provider, _) {
        // Filtering is the server's job now. The list only ever holds one page,
        // so matching locally would silently search a fraction of the data.
        final filtered = provider.reservations;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(l.reservations,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 20),
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(apiErrorText(context, provider.errorCode, provider.error), style: const TextStyle(color: Colors.red)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 16),
                        onPressed: provider.clearError,
                      ),
                    ]),
                  ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? _EmptyState(l: l)
                          : _ReservationsTable(
                              reservations: filtered,
                              l: l,
                              serviceNames: {
                                for (final s in context.watch<AdditionalServicesProvider>().services)
                                  s.id: s.name,
                              },
                              onApprove: (r) => _run(
                                  provider, () => provider.approve(r.id), 'Rezervacija je odobrena.'),
                              onConfirmCash: (r) => _run(provider, () => provider.confirmCash(r.id),
                                  'Gotovinska uplata je evidentirana.'),
                              onComplete: (r) => _run(provider, () => provider.complete(r.id),
                                  'Trening je označen kao završen.'),
                              onCancel: (r) => _promptCancel(context, provider, r, l),
                            ),
                ),
                // Page navigation over the API's PagedResult, so the admin list
                // never asks for the whole table (review item 22).
                PaginationBar(
                  page: provider.page,
                  pageSize: provider.pageSize,
                  totalCount: provider.totalCount,
                  isLoading: provider.isLoading,
                  onPageChanged: (p) => provider.loadReservations(page: p),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Runs a state-machine action and reports the outcome. A refusal from the backend
  /// (for example an illegal transition) is shown verbatim rather than swallowed.
  Future<void> _run(
    ReservationsProvider provider,
    Future<bool> Function() action,
    String successMessage,
  ) async {
    final ok = await action();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? successMessage : apiErrorText(context, provider.errorCode, provider.error)),
      backgroundColor: ok ? const Color(0xFF27AE60) : Colors.red,
    ));
  }

  /// Cancelling always requires a reason, which is stored with the reservation
  /// together with who cancelled it and when.
  void _promptCancel(
    BuildContext context,
    ReservationsProvider provider,
    Reservation r,
    AppLocalizations l,
  ) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: const Text('Otkaživanje rezervacije', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Otkazujete rezervaciju "${r.trainingName ?? '-'}" '
                  'za korisnika ${r.userName ?? '-'}.',
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
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.length < 3) return 'Unesite razlog (najmanje 3 znaka).';
                    return null;
                  },
                ),
                Text(
                  'Korisnik će primiti obavijest o otkazivanju.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final reason = reasonController.text.trim();
              Navigator.pop(dialogContext);
              _run(provider, () => provider.cancel(r.id, reason), 'Rezervacija je otkazana.');
            },
            child: const Text('Otkaži rezervaciju', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ReservationsTable extends StatelessWidget {
  final List<Reservation> reservations;
  final AppLocalizations l;

  /// Additional-service id to name, so the list can name what was booked rather
  /// than print raw ids.
  final Map<int, String> serviceNames;
  final void Function(Reservation) onApprove;
  final void Function(Reservation) onConfirmCash;
  final void Function(Reservation) onComplete;
  final void Function(Reservation) onCancel;

  const _ReservationsTable({
    required this.reservations,
    required this.l,
    required this.serviceNames,
    required this.onApprove,
    required this.onConfirmCash,
    required this.onComplete,
    required this.onCancel,
  });

  static const _p = EdgeInsets.symmetric(horizontal: 12, vertical: 12);

  Widget _h(String t) => Padding(
        padding: _p,
        child: Text(t,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
      );

  Widget _d(Widget w) => Padding(padding: _p, child: w);

  static Widget _action(IconData icon, Color color, String tooltip, VoidCallback onPressed) =>
      IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        constraints: const BoxConstraints(),
      );

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Container(
          decoration: const BoxDecoration(
              color: Color(0xFF152030),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            Expanded(flex: 2, child: _h(l.client)),
            Expanded(flex: 2, child: _h(l.training)),
            Expanded(flex: 2, child: _h(l.date)),
            Expanded(flex: 2, child: _h(l.type)),
            Expanded(flex: 2, child: _h('Dodatne usluge')),
            Expanded(flex: 1, child: _h('Iznos')),
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
                  Expanded(
                    flex: 2,
                    child: _d(Text(r.userName ?? '—',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis)),
                  ),
                  Expanded(
                    flex: 2,
                    child: _d(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.trainingName ?? '—',
                            style: const TextStyle(color: Colors.white70),
                            overflow: TextOverflow.ellipsis),
                        if (r.trainerName != null)
                          Text(r.trainerName!,
                              style: TextStyle(color: Colors.grey[600], fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                      ],
                    )),
                  ),
                  Expanded(
                    flex: 2,
                    child: _d(Row(children: [
                      Text(fmt.format(r.reservationDate),
                          style: const TextStyle(color: Colors.white70)),
                      if (r.isOutsideTrainerAvailability) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: 'Termin van radnog vremena trenera '
                              '(doplata ${formatMoney(r.outsideAvailabilitySurcharge)})',
                          child: const Icon(Icons.nightlight_round, color: Colors.amber, size: 15),
                        ),
                      ],
                    ])),
                  ),
                  Expanded(
                    flex: 2,
                    child: _d(Text(r.reservationType.label,
                        style: const TextStyle(color: Colors.white70, fontSize: 12))),
                  ),
                  Expanded(
                    flex: 2,
                    child: _d(_ServicesCell(ids: r.additionalServiceIds, names: serviceNames)),
                  ),
                  Expanded(
                    flex: 1,
                    child: _d(Row(children: [
                      Text(r.totalPrice.toStringAsFixed(2),
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 5),
                      Icon(
                        r.isPaid ? Icons.check_circle : Icons.schedule,
                        size: 13,
                        color: r.isPaid ? Colors.green : Colors.orange,
                      ),
                      // A monthly booking costs 0 because a package session paid for it.
                      if (r.userMembershipId != null) ...[
                        const SizedBox(width: 5),
                        const Tooltip(
                          message: 'Plaćeno iz mjesečnog paketa',
                          child: Icon(Icons.card_membership, size: 13, color: Color(0xFF4A90D9)),
                        ),
                      ],
                    ])),
                  ),
                  Expanded(flex: 2, child: _d(_StatusBadge(r.status, l))),

                  // Which actions appear is driven by allowedNextStatuses from the API,
                  // so the UI can never offer a transition the state machine would reject.
                  Expanded(
                    flex: 2,
                    child: _d(Row(mainAxisSize: MainAxisSize.min, children: [
                      if (r.canApprove)
                        _action(Icons.check_circle, Colors.green, l.approve, () => onApprove(r)),
                      if (r.canConfirmCash)
                        _action(Icons.payments, Colors.tealAccent,
                            'Evidentiraj gotovinsku uplatu', () => onConfirmCash(r)),
                      if (r.canComplete)
                        _action(Icons.task_alt, Colors.purpleAccent, 'Označi kao završeno',
                            () => onComplete(r)),
                      if (r.canCancel)
                        _action(Icons.cancel, Colors.orange, l.cancel, () => onCancel(r)),
                      if (!r.canApprove && !r.canConfirmCash && !r.canComplete && !r.canCancel)
                        Tooltip(
                          message: r.cancellationReason ?? 'Nema dostupnih akcija',
                          child: Text('—', style: TextStyle(color: Colors.grey[600])),
                        ),
                    ])),
                  ),
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
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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

/// Lists the additional services booked with a reservation.
///
/// Review item 18: every repository read path now includes `ReservationServices`,
/// so this column is populated in the admin list exactly as it is for the client.
/// Before that fix the admin list came back with an empty set even when services
/// existed in the database.
class _ServicesCell extends StatelessWidget {
  final List<int> ids;
  final Map<int, String> names;

  const _ServicesCell({required this.ids, required this.names});

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) {
      return Text('-', style: TextStyle(color: Colors.grey[600], fontSize: 12));
    }

    // Fall back to the raw id if the catalogue has not loaded yet, or if the
    // service was deleted after the booking was made.
    final labels = ids.map((id) => names[id] ?? '#$id').toList();

    return Tooltip(
      message: labels.join(', '),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: labels
            .map((name) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    name,
                    style: const TextStyle(color: Color(0xFF4A90D9), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
