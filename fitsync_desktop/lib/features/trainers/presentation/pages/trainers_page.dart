import 'package:flutter/material.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import '../../../../core/error/api_error_messages.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/trainer.dart';
import '../../domain/entities/trainer_availability.dart';
import '../providers/trainers_provider.dart';
import '../../../../core/utils/money.dart';

/// Trainers and their weekly working hours.
///
/// The availability windows maintained here are what `TrainerAvailability` checks
/// during booking: a slot that fits no window needs an explicit out-of-hours
/// request and picks up the trainer's surcharge (review item 19). Without this
/// screen those windows could only be changed through Swagger.
class TrainersPage extends StatefulWidget {
  /// False when the page is shown inside the staff tabs, which already carry a
  /// heading of their own.
  final bool showHeading;

  const TrainersPage({super.key, this.showHeading = false});

  @override
  State<TrainersPage> createState() => _TrainersPageState();
}

class _TrainersPageState extends State<TrainersPage> {
  int? _expandedTrainerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainersProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainersProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                if (widget.showHeading)
                  Text(AppLocalizations.of(context).navTrainersTab,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Dodaj trenera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8622A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showTrainerDialog(context, provider),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: provider.load,
                  tooltip: 'Osvježi',
                ),
              ]),
              const SizedBox(height: 20),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(apiErrorText(context, provider.errorCode, provider.error), style: const TextStyle(color: Colors.red))),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 16),
                      onPressed: provider.clearError,
                    ),
                  ]),
                ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.trainers.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            itemCount: provider.trainers.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (ctx, i) {
                              final t = provider.trainers[i];
                              return _TrainerCard(
                                trainer: t,
                                expanded: _expandedTrainerId == t.id,
                                onToggle: () => setState(() =>
                                    _expandedTrainerId = _expandedTrainerId == t.id ? null : t.id),
                                onEdit: () => _showTrainerDialog(context, provider, trainer: t),
                                onDelete: () => _confirmDeleteTrainer(context, provider, t),
                                onAddAvailability: () =>
                                    _showAvailabilityDialog(context, provider, t),
                                onDeleteAvailability: (a) =>
                                    _confirmDeleteAvailability(context, provider, a),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrainerDialog(BuildContext context, TrainersProvider provider, {Trainer? trainer}) {
    final firstCtrl = TextEditingController(text: trainer?.firstName ?? '');
    final lastCtrl = TextEditingController(text: trainer?.lastName ?? '');
    final specialtyCtrl = TextEditingController(text: trainer?.specialty ?? '');
    final emailCtrl = TextEditingController(text: trainer?.email ?? '');
    final phoneCtrl = TextEditingController(text: trainer?.phoneNumber ?? '');
    final bioCtrl = TextEditingController(text: trainer?.biography ?? '');
    final surchargeCtrl = TextEditingController(
        text: (trainer?.outsideAvailabilitySurcharge ?? 0).toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(trainer == null ? 'Dodaj trenera' : 'Uredi trenera',
            style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(child: _field('Ime', firstCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _field('Prezime', lastCtrl)),
              ]),
              const SizedBox(height: 12),
              _field('Specijalnost', specialtyCtrl),
              const SizedBox(height: 12),
              _field('Email', emailCtrl),
              const SizedBox(height: 12),
              _field('Telefon', phoneCtrl),
              const SizedBox(height: 12),
              _field('Biografija', bioCtrl, maxLines: 3),
              const SizedBox(height: 12),
              _field('Doplata van radnog vremena (BAM)', surchargeCtrl, number: true),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Otkaži')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A)),
            onPressed: () async {
              if (firstCtrl.text.trim().isEmpty || lastCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);

              final edited = Trainer(
                id: trainer?.id ?? 0,
                firstName: firstCtrl.text.trim(),
                lastName: lastCtrl.text.trim(),
                specialty: specialtyCtrl.text.trim().isEmpty ? null : specialtyCtrl.text.trim(),
                email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                phoneNumber: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                biography: bioCtrl.text.trim().isEmpty ? null : bioCtrl.text.trim(),
                outsideAvailabilitySurcharge:
                    double.tryParse(surchargeCtrl.text.replaceAll(',', '.')) ?? 0,
                userId: trainer?.userId,
              );

              final ok = trainer == null
                  ? await provider.add(edited)
                  : await provider.edit(trainer.id, edited);

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok ? 'Trener je sačuvan' : apiErrorText(context, provider.errorCode, provider.error)),
                backgroundColor: ok ? const Color(0xFF27AE60) : Colors.red,
              ));
            },
            child: const Text('Sačuvaj', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAvailabilityDialog(BuildContext context, TrainersProvider provider, Trainer trainer) {
    int dayOfWeek = 1; // Monday
    TimeOfDay start = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 17, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2535),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Radno vrijeme - ${trainer.fullName}',
              style: const TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 420,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<int>(
                initialValue: dayOfWeek,
                dropdownColor: const Color(0xFF1E2A3A),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Dan',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFF243347),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                // 0 = Sunday, matching System.DayOfWeek on the API.
                items: List.generate(
                  TrainerAvailability.dayNames.length,
                  (i) => DropdownMenuItem(
                      value: i, child: Text(TrainerAvailability.dayNames[i])),
                ),
                onChanged: (v) => setDlgState(() => dayOfWeek = v ?? 1),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: _TimeButton(
                    label: 'Pocetak',
                    time: start,
                    onPick: (t) => setDlgState(() => start = t),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeButton(
                    label: 'Kraj',
                    time: end,
                    onPick: (t) => setDlgState(() => end = t),
                  ),
                ),
              ]),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Otkaži')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A)),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                // The API validates that the end is after the start and rejects
                // the request otherwise; its message is what gets shown.
                final ok = await provider.addAvailability(
                  trainerId: trainer.id,
                  dayOfWeek: dayOfWeek,
                  startMinutes: start.hour * 60 + start.minute,
                  endMinutes: end.hour * 60 + end.minute,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Termin je dodan' : apiErrorText(context, provider.errorCode, provider.error)),
                  backgroundColor: ok ? const Color(0xFF27AE60) : Colors.red,
                ));
              },
              child: const Text('Dodaj', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTrainer(BuildContext context, TrainersProvider provider, Trainer t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2535),
        title: const Text('Brisanje trenera', style: TextStyle(color: Colors.white)),
        content: Text('Obrisati trenera "${t.fullName}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Otkaži')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await provider.remove(t.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok ? 'Trener je obrisan' : apiErrorText(context, provider.errorCode, provider.error)),
                backgroundColor: ok ? const Color(0xFF27AE60) : Colors.red,
              ));
            },
            child: const Text('Obriši', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAvailability(
      BuildContext context, TrainersProvider provider, TrainerAvailability a) async {
    final ok = await provider.removeAvailability(a.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Termin je uklonjen' : apiErrorText(context, provider.errorCode, provider.error)),
      backgroundColor: ok ? const Color(0xFF27AE60) : Colors.red,
    ));
  }

  Widget _field(String label, TextEditingController ctrl,
          {bool number = false, int maxLines = 1}) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: const Color(0xFF243347),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE8622A)),
          ),
        ),
      );
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final void Function(TimeOfDay) onPick;

  const _TimeButton({required this.label, required this.time, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF243347),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          const Icon(Icons.access_time, color: Colors.white54, size: 18),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  final Trainer trainer;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddAvailability;
  final void Function(TrainerAvailability) onDeleteAvailability;

  const _TrainerCard({
    required this.trainer,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onAddAvailability,
    required this.onDeleteAvailability,
  });

  @override
  Widget build(BuildContext context) {
    // Sunday-first ordering matches the day indexes the API uses.
    final sorted = [...trainer.availabilities]..sort((a, b) {
        if (a.dayOfWeek != b.dayOfWeek) return a.dayOfWeek.compareTo(b.dayOfWeek);
        return a.startMinutes.compareTo(b.startMinutes);
      });

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE8622A).withValues(alpha: 0.2),
                child: Text(
                  trainer.firstName.isNotEmpty ? trainer.firstName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Color(0xFFE8622A), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(trainer.fullName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  if (trainer.specialty != null)
                    Text(trainer.specialty!,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ]),
              ),
              Expanded(
                flex: 2,
                child: Text(trainer.email ?? '-',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                flex: 2,
                child: Row(children: [
                  const Icon(Icons.nightlight_round, color: Colors.amber, size: 14),
                  const SizedBox(width: 6),
                  Text(formatMoney(trainer.outsideAvailabilitySurcharge),
                      style: const TextStyle(color: Colors.amber, fontSize: 12)),
                ]),
              ),
              Expanded(
                flex: 1,
                child: Text('${sorted.length} termina',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF4A90D9), size: 18),
                onPressed: onEdit,
                tooltip: 'Uredi',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                onPressed: onDelete,
                tooltip: 'Obriši',
              ),
              Icon(expanded ? Icons.expand_less : Icons.expand_more, color: Colors.white54),
            ]),
          ),
        ),
        if (expanded) ...[
          const Divider(height: 1, color: Colors.white12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Radno vrijeme',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFFE8622A)),
                  label: const Text('Dodaj termin',
                      style: TextStyle(color: Color(0xFFE8622A), fontSize: 13)),
                  onPressed: onAddAvailability,
                ),
              ]),
              const SizedBox(height: 8),
              if (sorted.isEmpty)
                Text(
                  'Nema definisanog radnog vremena - svaka rezervacija kod ovog trenera '
                  'racuna se kao termin van radnog vremena.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sorted
                      .map((a) => Chip(
                            backgroundColor: const Color(0xFF243347),
                            side: BorderSide.none,
                            label: Text('${a.dayName} ${a.startLabel}-${a.endLabel}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            deleteIcon: const Icon(Icons.close, size: 14, color: Colors.red),
                            onDeleted: () => onDeleteAvailability(a),
                          ))
                      .toList(),
                ),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.sports, size: 56, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text('Nema evidentiranih trenera', style: TextStyle(color: Colors.grey[500])),
        ]),
      );
}
