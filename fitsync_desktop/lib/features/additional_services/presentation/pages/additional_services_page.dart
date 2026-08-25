import 'package:flutter/material.dart';
import '../../../../core/error/api_error_messages.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/additional_service.dart';
import '../providers/additional_services_provider.dart';
import '../../../../core/utils/money.dart';

class AdditionalServicesPage extends StatefulWidget {
  const AdditionalServicesPage({super.key});

  @override
  State<AdditionalServicesPage> createState() => _AdditionalServicesPageState();
}

class _AdditionalServicesPageState extends State<AdditionalServicesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdditionalServicesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Consumer<AdditionalServicesProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(l.navAdditionalServices,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.addAdditionalService),
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
                  child: Text(apiErrorText(context, provider.errorCode, provider.error), style: const TextStyle(color: Colors.red)),
                ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.services.isEmpty
                        ? _EmptyState(l: l)
                        : _ServicesTable(
                            services: provider.services,
                            l: l,
                            onEdit: (s) => _showDialog(context, provider, service: s),
                            onDelete: (s) => _confirmDelete(context, provider, s, l),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, AdditionalServicesProvider provider, {AdditionalService? service}) {
    final nameCtrl = TextEditingController(text: service?.name ?? '');
    final priceCtrl = TextEditingController(text: service?.price.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          service == null ? 'Dodaj dodatnu uslugu' : 'Uredi dodatnu uslugu',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Naziv'),
                validator: (v) => (v == null || v.isEmpty) ? 'Obavezno' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Cijena (\$)'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Obavezno';
                  if (double.tryParse(v) == null) return 'Neispravan broj';
                  return null;
                },
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Otkaži')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A)),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              final name = nameCtrl.text.trim();
              final price = double.parse(priceCtrl.text);
              if (service == null) {
                await provider.add(name, price);
              } else {
                await provider.edit(service.id, name, price);
              }
            },
            child: const Text('Sačuvaj', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey[400]),
    filled: true,
    fillColor: const Color(0xFF243347),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE8622A)),
    ),
  );

  void _confirmDelete(BuildContext context, AdditionalServicesProvider provider, AdditionalService service, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: const Text('Obriši uslugu', style: TextStyle(color: Colors.white)),
        content: Text('Obrisati "${service.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async { Navigator.pop(context); await provider.remove(service.id); },
            child: Text(l.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ServicesTable extends StatelessWidget {
  final List<AdditionalService> services;
  final AppLocalizations l;
  final void Function(AdditionalService) onEdit;
  final void Function(AdditionalService) onDelete;

  const _ServicesTable({required this.services, required this.l, required this.onEdit, required this.onDelete});

  static const _p = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  Widget _h(String t) => Padding(padding: _p,
      child: Text(t, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)));
  Widget _d(Widget w) => Padding(padding: _p, child: w);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Container(
          decoration: const BoxDecoration(color: Color(0xFF152030),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            Expanded(flex: 5, child: _h('Naziv')),
            Expanded(flex: 2, child: _h('Cijena')),
            Expanded(flex: 2, child: _h('Akcije')),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: services.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
            itemBuilder: (ctx, i) {
              final s = services[i];
              return InkWell(
                hoverColor: const Color(0xFF243347),
                child: Row(children: [
                  Expanded(flex: 5, child: _d(Text(s.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)))),
                  Expanded(flex: 2, child: _d(Text(formatMoney(s.price),
                      style: const TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.w600)))),
                  Expanded(flex: 2, child: _d(Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF4A90D9), size: 20),
                      onPressed: () => onEdit(s),
                      tooltip: 'Uredi',
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => onDelete(s),
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
      Icon(Icons.add_box_outlined, size: 64, color: Colors.grey[700]),
      const SizedBox(height: 16),
      Text('Nema dodatnih usluga', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
    ]),
  );
}
