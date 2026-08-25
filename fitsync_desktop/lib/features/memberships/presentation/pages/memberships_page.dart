import 'package:flutter/material.dart';
import '../../../../core/error/api_error_messages.dart';
import 'package:provider/provider.dart';
import '../../../training_types/domain/entities/training_type.dart';
import '../../../training_types/presentation/providers/training_types_provider.dart';
import '../../domain/entities/membership_package.dart';
import '../providers/memberships_provider.dart';
import '../../../../core/utils/money.dart';

/// Administration of the monthly packages sold in the mobile app.
///
/// Review item 19 made monthly reservations a real feature; this screen is where
/// the packages behind them are maintained. Prices, session counts and validity
/// are what the client app then shows and what a monthly booking spends.
class MembershipsPage extends StatefulWidget {
  const MembershipsPage({super.key});

  @override
  State<MembershipsPage> createState() => _MembershipsPageState();
}

class _MembershipsPageState extends State<MembershipsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipsProvider>().load();
      // Needed for the "restricted to training type" picker.
      context.read<TrainingTypesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MembershipsProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Mjesečni paketi',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj paket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8622A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showDialog(context, provider),
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
                    : provider.packages.isEmpty
                        ? const _EmptyState()
                        : _PackagesTable(
                            packages: provider.packages,
                            onEdit: (p) => _showDialog(context, provider, package: p),
                            onDelete: (p) => _confirmDelete(context, provider, p),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, MembershipsProvider provider,
      {MembershipPackage? package}) {
    final nameCtrl = TextEditingController(text: package?.name ?? '');
    final descCtrl = TextEditingController(text: package?.description ?? '');
    final daysCtrl = TextEditingController(text: (package?.durationDays ?? 30).toString());
    final sessionsCtrl = TextEditingController(text: (package?.sessionCount ?? 8).toString());
    final priceCtrl = TextEditingController(text: (package?.price ?? 0).toStringAsFixed(2));
    int? trainingTypeId = package?.trainingTypeId;
    bool isActive = package?.isActive ?? true;

    final types = context.read<TrainingTypesProvider>().types;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2535),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(package == null ? 'Dodaj paket' : 'Uredi paket',
              style: const TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _field('Naziv', nameCtrl),
                const SizedBox(height: 12),
                _field('Opis', descCtrl, maxLines: 2),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field('Trajanje (dana)', daysCtrl, number: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Broj termina', sessionsCtrl, number: true)),
                ]),
                const SizedBox(height: 12),
                _field('Cijena (BAM)', priceCtrl, number: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: trainingTypeId,
                  dropdownColor: const Color(0xFF1E2A3A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Ograničen na tip treninga',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFF243347),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  items: <DropdownMenuItem<int?>>[
                    const DropdownMenuItem<int?>(value: null, child: Text('Svi tipovi')),
                    ...types.map((TrainingType t) =>
                        DropdownMenuItem<int?>(value: t.id, child: Text(t.name))),
                  ],
                  onChanged: (v) => setDlgState(() => trainingTypeId = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isActive,
                  onChanged: (v) => setDlgState(() => isActive = v),
                  activeThumbColor: const Color(0xFFE8622A),
                  title: const Text('U prodaji', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    isActive ? 'Vidljiv u mobilnoj aplikaciji' : 'Sakriven od klijenata',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Otkaži')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A)),
              onPressed: () async {
                // Ranges (price > 0, 1..366 days, 1..200 sessions) are enforced by
                // the API; this only stops an obviously empty submit.
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);

                final edited = MembershipPackage(
                  id: package?.id ?? 0,
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  durationDays: int.tryParse(daysCtrl.text) ?? 30,
                  sessionCount: int.tryParse(sessionsCtrl.text) ?? 0,
                  price: double.tryParse(priceCtrl.text.replaceAll(',', '.')) ?? 0,
                  trainingTypeId: trainingTypeId,
                  isActive: isActive,
                  pricePerSession: 0,
                );

                final ok = package == null
                    ? await provider.add(edited)
                    : await provider.edit(package.id, edited);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Paket je sačuvan' : apiErrorText(context, provider.errorCode, provider.error)),
                  backgroundColor: ok ? const Color(0xFF27AE60) : Colors.red,
                ));
              },
              child: const Text('Sačuvaj', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MembershipsProvider provider, MembershipPackage p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2535),
        title: const Text('Brisanje paketa', style: TextStyle(color: Colors.white)),
        content: Text('Obrisati paket "${p.name}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Otkaži')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await provider.remove(p.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok ? 'Paket je obrisan' : apiErrorText(context, provider.errorCode, provider.error)),
                backgroundColor: ok ? const Color(0xFF27AE60) : Colors.red,
              ));
            },
            child: const Text('Obriši', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

class _PackagesTable extends StatelessWidget {
  final List<MembershipPackage> packages;
  final void Function(MembershipPackage) onEdit;
  final void Function(MembershipPackage) onDelete;

  const _PackagesTable({
    required this.packages,
    required this.onEdit,
    required this.onDelete,
  });

  static const _p = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  Widget _h(String t) => Padding(
      padding: _p,
      child: Text(t,
          style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)));
  Widget _d(Widget w) => Padding(padding: _p, child: w);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Container(
          decoration: const BoxDecoration(
              color: Color(0xFF152030),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            Expanded(flex: 3, child: _h('Naziv')),
            Expanded(flex: 1, child: _h('Termina')),
            Expanded(flex: 1, child: _h('Dana')),
            Expanded(flex: 2, child: _h('Cijena')),
            Expanded(flex: 2, child: _h('Tip treninga')),
            Expanded(flex: 1, child: _h('Status')),
            Expanded(flex: 2, child: _h('Akcije')),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: packages.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.white12),
            itemBuilder: (ctx, i) {
              final p = packages[i];
              return Row(children: [
                Expanded(
                  flex: 3,
                  child: _d(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    if (p.description != null)
                      Text(p.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ])),
                ),
                Expanded(
                    flex: 1,
                    child: _d(Text('${p.sessionCount}',
                        style: const TextStyle(color: Colors.white70)))),
                Expanded(
                    flex: 1,
                    child: _d(Text('${p.durationDays}',
                        style: const TextStyle(color: Colors.white70)))),
                Expanded(
                  flex: 2,
                  child: _d(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(formatMoney(p.price),
                        style: const TextStyle(color: Color(0xFFE8622A), fontWeight: FontWeight.w600)),
                    Text('${p.pricePerSession.toStringAsFixed(2)} / termin',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ])),
                ),
                Expanded(
                  flex: 2,
                  child: _d(Text(p.coversAllTypes ? 'Svi tipovi' : (p.trainingTypeName ?? '-'),
                      style: const TextStyle(color: Colors.white70, fontSize: 12))),
                ),
                Expanded(flex: 1, child: _d(_ActiveBadge(isActive: p.isActive))),
                Expanded(
                  flex: 2,
                  child: _d(Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF4A90D9), size: 18),
                      onPressed: () => onEdit(p),
                      tooltip: 'Uredi',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => onDelete(p),
                      tooltip: 'Obriši',
                    ),
                  ])),
                ),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool isActive;
  const _ActiveBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF2E7D32) : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(isActive ? 'Aktivan' : 'Skriven',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.card_membership, size: 56, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text('Nema definisanih paketa', style: TextStyle(color: Colors.grey[500])),
        ]),
      );
}
