import 'package:flutter/material.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/training_type.dart';
import '../providers/training_types_provider.dart';

class TrainingTypesPage extends StatefulWidget {
  const TrainingTypesPage({super.key});

  @override
  State<TrainingTypesPage> createState() => _TrainingTypesPageState();
}

class _TrainingTypesPageState extends State<TrainingTypesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingTypesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<TrainingTypesProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(l.navTrainingTypes,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.addTrainingType),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8622A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showDialog(context, provider),
                ),
              ]),
              const SizedBox(height: 20),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
                ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.types.isEmpty
                        ? _EmptyState(l: l)
                        : _TypesTable(
                            types: provider.types,
                            l: l,
                            onEdit: (t) => _showDialog(context, provider, type: t),
                            onDelete: (t) => _confirmDelete(context, provider, t, l),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, TrainingTypesProvider provider, {TrainingType? type}) {
    final ctrl = TextEditingController(text: type?.name ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          type == null ? 'Dodaj vrstu treninga' : 'Uredi vrstu treninga',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 360,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Naziv',
              labelStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFF243347),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE8622A)),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Otkazi')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A)),
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              if (type == null) {
                await provider.add(ctrl.text.trim());
              } else {
                await provider.edit(type.id, ctrl.text.trim());
              }
            },
            child: const Text('Sacuvaj', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TrainingTypesProvider provider, TrainingType type, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: const Text('Obrisi vrstu treninga', style: TextStyle(color: Colors.white)),
        content: Text('Obrisati "${type.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async { Navigator.pop(context); await provider.remove(type.id); },
            child: Text(l.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _TypesTable extends StatelessWidget {
  final List<TrainingType> types;
  final AppLocalizations l;
  final void Function(TrainingType) onEdit;
  final void Function(TrainingType) onDelete;

  const _TypesTable({required this.types, required this.l, required this.onEdit, required this.onDelete});

  static const _p = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Container(
          decoration: const BoxDecoration(color: Color(0xFF152030),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            Expanded(flex: 1, child: Padding(padding: _p,
                child: const Text('#', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)))),
            Expanded(flex: 6, child: Padding(padding: _p,
                child: const Text('Naziv', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)))),
            Expanded(flex: 2, child: Padding(padding: _p,
                child: const Text('Akcije', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)))),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: types.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
            itemBuilder: (ctx, i) {
              final t = types[i];
              return InkWell(
                hoverColor: const Color(0xFF243347),
                child: Row(children: [
                  Expanded(flex: 1, child: Padding(padding: _p,
                      child: Text('${i + 1}', style: TextStyle(color: Colors.grey[500])))),
                  Expanded(flex: 6, child: Padding(padding: _p,
                      child: Text(t.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)))),
                  Expanded(flex: 2, child: Padding(padding: _p,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF4A90D9), size: 20),
                      onPressed: () => onEdit(t),
                      tooltip: 'Uredi',
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => onDelete(t),
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

class _EmptyState extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyState({required this.l});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.category, size: 64, color: Colors.grey[700]),
      const SizedBox(height: 16),
      Text('Nema vrsta treninga', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
    ]),
  );
}
