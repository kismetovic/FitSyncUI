import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/training.dart';
import '../../domain/entities/training_difficulty.dart';
import '../providers/trainings_provider.dart';
import '../../../training_types/domain/usecases/get_training_types.dart';
import '../../../training_types/domain/entities/training_type.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart' as di;

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  final _searchController = TextEditingController();
  List<TrainingType> _trainingTypes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<TrainingsProvider>().loadTrainings();
      final result = await di.sl<GetTrainingTypes>().call(NoParams());
      result.fold((_) {}, (types) => setState(() => _trainingTypes = types));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Trainings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold,
                    )),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Training'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8622A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showTrainingDialog(context, provider),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search trainings...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    filled: true,
                    fillColor: const Color(0xFF1E2A3A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => provider.loadTrainings(v.isEmpty ? null : v),
                ),
                const SizedBox(height: 20),
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
                  ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.trainings.isEmpty
                          ? _EmptyState(message: 'No trainings found')
                          : _TrainingsTable(
                              trainings: provider.trainings,
                              onEdit: (t) => _showTrainingDialog(context, provider, training: t),
                              onDelete: (t) => _confirmDelete(context, provider, t),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTrainingDialog(BuildContext context, TrainingsProvider provider, {Training? training}) {
    showDialog(
      context: context,
      builder: (_) => _TrainingDialog(
        training: training,
        trainingTypes: _trainingTypes,
        onSave: (data) async {
          bool ok;
          if (training == null) {
            ok = await provider.addTraining(
              name: data['name'],
              description: data['description'],
              price: data['price'],
              durationMinutes: data['durationMinutes'],
              maxCapacity: data['maxCapacity'],
              difficulty: data['difficulty'],
              trainingTypeId: data['trainingTypeId'],
            );
          } else {
            ok = await provider.editTraining(
              training.id,
              name: data['name'],
              description: data['description'],
              price: data['price'],
              durationMinutes: data['durationMinutes'],
              maxCapacity: data['maxCapacity'],
              difficulty: data['difficulty'],
              trainingTypeId: data['trainingTypeId'],
            );
          }
          if (ok && context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, TrainingsProvider provider, Training training) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: const Text('Delete Training', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${training.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await provider.removeTraining(training.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _TrainingsTable extends StatelessWidget {
  final List<Training> trainings;
  final void Function(Training) onEdit;
  final void Function(Training) onDelete;

  const _TrainingsTable({required this.trainings, required this.onEdit, required this.onDelete});

  static const _p = EdgeInsets.symmetric(horizontal: 12, vertical: 12);
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
            Expanded(flex: 3, child: _h('Naziv')),
            Expanded(flex: 2, child: _h('Tip')),
            Expanded(flex: 1, child: _h('Cijena')),
            Expanded(flex: 2, child: _h('Trajanje')),
            Expanded(flex: 1, child: _h('Kapacitet')),
            Expanded(flex: 2, child: _h('Tezina')),
            Expanded(flex: 1, child: _h('Ocjena')),
            Expanded(flex: 1, child: _h('Akcije')),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: trainings.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
            itemBuilder: (ctx, i) {
              final t = trainings[i];
              return InkWell(
                hoverColor: const Color(0xFF243347),
                child: Row(children: [
                  Expanded(flex: 3, child: _d(Text(t.name,
                      style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis))),
                  Expanded(flex: 2, child: _d(Text(t.trainingTypeName ?? '—',
                      style: const TextStyle(color: Colors.white70), overflow: TextOverflow.ellipsis))),
                  Expanded(flex: 1, child: _d(Text('\$${t.price.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white)))),
                  Expanded(flex: 2, child: _d(Text('${t.durationMinutes} min',
                      style: const TextStyle(color: Colors.white70)))),
                  Expanded(flex: 1, child: _d(Text('${t.maxCapacity}',
                      style: const TextStyle(color: Colors.white70)))),
                  Expanded(flex: 2, child: _d(_DifficultyBadge(t.difficulty))),
                  Expanded(flex: 1, child: _d(Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    Text(t.averageRating?.toStringAsFixed(1) ?? '—',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ]))),
                  Expanded(flex: 1, child: _d(Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF4A90D9), size: 18),
                      onPressed: () => onEdit(t),
                      tooltip: 'Edit',
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => onDelete(t),
                      tooltip: 'Delete',
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

class _DifficultyBadge extends StatelessWidget {
  final TrainingDifficulty difficulty;
  const _DifficultyBadge(this.difficulty);

  @override
  Widget build(BuildContext context) {
    final colors = {
      TrainingDifficulty.beginner: Colors.green,
      TrainingDifficulty.intermediate: Colors.orange,
      TrainingDifficulty.advanced: Colors.red,
    };
    final color = colors[difficulty] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        difficulty.name[0].toUpperCase() + difficulty.name.substring(1),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TrainingDialog extends StatefulWidget {
  final Training? training;
  final List<TrainingType> trainingTypes;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const _TrainingDialog({this.training, required this.trainingTypes, required this.onSave});

  @override
  State<_TrainingDialog> createState() => _TrainingDialogState();
}

class _TrainingDialogState extends State<_TrainingDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _description, _price, _duration, _capacity;
  TrainingDifficulty _difficulty = TrainingDifficulty.beginner;
  int? _selectedTypeId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.training;
    _name = TextEditingController(text: t?.name ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _price = TextEditingController(text: t?.price.toString() ?? '');
    _duration = TextEditingController(text: t?.durationMinutes.toString() ?? '60');
    _capacity = TextEditingController(text: t?.maxCapacity.toString() ?? '10');
    _difficulty = t?.difficulty ?? TrainingDifficulty.beginner;
    _selectedTypeId = t?.trainingTypeId;
    if (_selectedTypeId == null && widget.trainingTypes.isNotEmpty) {
      _selectedTypeId = widget.trainingTypes.first.id;
    }
  }

  @override
  void dispose() {
    _name.dispose(); _description.dispose(); _price.dispose();
    _duration.dispose(); _capacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A2535),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.training == null ? 'Add Training' : 'Edit Training',
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('Name', _name, required: true),
                const SizedBox(height: 12),
                _field('Description', _description, maxLines: 3),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field('Price (\$)', _price, numeric: true, required: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Duration (min)', _duration, numeric: true, required: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Capacity', _capacity, numeric: true, required: true)),
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<TrainingDifficulty>(
                  initialValue: _difficulty,
                  dropdownColor: const Color(0xFF1E2A3A),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Difficulty'),
                  items: TrainingDifficulty.values.map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(d.name[0].toUpperCase() + d.name.substring(1)),
                  )).toList(),
                  onChanged: (v) => setState(() => _difficulty = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _selectedTypeId,
                  dropdownColor: const Color(0xFF1E2A3A),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Training Type'),
                  items: widget.trainingTypes.map((t) => DropdownMenuItem(
                    value: t.id,
                    child: Text(t.name),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedTypeId = v),
                  validator: (v) => v == null ? 'Select a type' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A)),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool required = false, bool numeric = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label),
      validator: (v) {
        if (required && (v == null || v.isEmpty)) return 'Required';
        if (numeric && v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Invalid number';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.onSave({
      'name': _name.text,
      'description': _description.text,
      'price': double.parse(_price.text),
      'durationMinutes': int.parse(_duration.text),
      'maxCapacity': int.parse(_capacity.text),
      'difficulty': _difficulty,
      'trainingTypeId': _selectedTypeId!,
    });
    if (mounted) setState(() => _saving = false);
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.fitness_center, size: 64, color: Colors.grey[700]),
        const SizedBox(height: 16),
        Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
      ],
    ),
  );
}
