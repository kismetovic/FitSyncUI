import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/training.dart';
import '../../domain/entities/training_difficulty.dart';
import '../providers/trainings_provider.dart';
import '../../domain/entities/recommended_training.dart';
import '../providers/recommendations_provider.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import 'training_detail_page.dart';
import '../../../../core/utils/money.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingsProvider>().loadTrainings();
      context.read<RecommendationsProvider>().loadRecommendations();
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context, TrainingsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<TrainingsProvider, RecommendationsProvider, NotificationsProvider>(
      builder: (context, trainingsProvider, recommendationsProvider, notificationsProvider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  unreadCount: notificationsProvider.unreadCount,
                  onNotificationsTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: notificationsProvider,
                        child: const NotificationsPage(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).searchTrainings,
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                            filled: true,
                            fillColor: const Color(0xFF1E2A3A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (v) => trainingsProvider.loadTrainings(v.isEmpty ? null : v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        activeCount: trainingsProvider.activeFilterCount,
                        onTap: () => _showFilterSheet(context, trainingsProvider),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: trainingsProvider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8622A)))
                      : trainingsProvider.error != null
                          ? _ErrorView(error: trainingsProvider.error!, onRetry: () => trainingsProvider.loadTrainings())
                          : _scrollBody(context, trainingsProvider, recommendationsProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _scrollBody(
    BuildContext context,
    TrainingsProvider trainingsProvider,
    RecommendationsProvider recommendationsProvider,
  ) {
    final showRecommendations = recommendationsProvider.recommendations.isNotEmpty &&
        _searchController.text.isEmpty;
    final filtered = trainingsProvider.trainings;

    return CustomScrollView(
      slivers: [
        if (showRecommendations) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFE8622A), size: 18),
                  SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).recommended,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 248,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: recommendationsProvider.recommendations.length,
                itemBuilder: (context, index) => _RecommendationCard(
                  training: recommendationsProvider.recommendations[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrainingDetailPage(
                        training: recommendationsProvider.recommendations[index],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).allTrainings,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (trainingsProvider.hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: trainingsProvider.clearFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8622A).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8622A).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${trainingsProvider.activeFilterCount} filter${trainingsProvider.activeFilterCount > 1 ? 's' : ''} · clear',
                        style: const TextStyle(color: Color(0xFFE8622A), fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        if (filtered.isEmpty)
          SliverToBoxAdapter(
            child: trainingsProvider.hasActiveFilters
                ? _FilteredEmptyView(onClear: trainingsProvider.clearFilters)
                : const _EmptyView(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _TrainingCard(
                  training: filtered[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TrainingDetailPage(training: filtered[i])),
                  ),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _FilterButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = activeCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE8622A).withValues(alpha: 0.15) : const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? const Color(0xFFE8622A) : Colors.white12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(Icons.tune, color: active ? const Color(0xFFE8622A) : Colors.white70, size: 22),
            if (active)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(color: Color(0xFFE8622A), shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      '$activeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final TrainingsProvider provider;
  const _FilterSheet({required this.provider});

  static const _diffColors = {
    TrainingDifficulty.beginner: Colors.green,
    TrainingDifficulty.intermediate: Colors.orange,
    TrainingDifficulty.advanced: Colors.red,
  };

  static const _sortOptions = [
    ('Default', 'default'),
    ('Price ↑', 'price_asc'),
    ('Price ↓', 'price_desc'),
    ('Top Rated', 'rating'),
    ('Duration', 'duration'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1A2535),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(AppLocalizations.of(context).filters,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (provider.hasActiveFilters)
                    TextButton(
                      onPressed: provider.clearFilters,
                      child: Text(AppLocalizations.of(context).clearAll, style: TextStyle(color: Color(0xFFE8622A))),
                    ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(AppLocalizations.of(context).difficulty,
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: TrainingDifficulty.values.map((d) {
                  final color = _diffColors[d]!;
                  final selected = provider.selectedDifficulties.contains(d);
                  return FilterChip(
                    label: Text(d.label),
                    selected: selected,
                    onSelected: (_) => provider.toggleDifficulty(d),
                    selectedColor: color.withValues(alpha: 0.2),
                    checkmarkColor: color,
                    labelStyle: TextStyle(color: selected ? color : Colors.white70, fontSize: 13),
                    backgroundColor: const Color(0xFF243347),
                    side: BorderSide(color: selected ? color : Colors.white12),
                  );
                }).toList(),
              ),
              if (provider.availableTypes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).type,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _typeChip(context, null, provider),
                    ...provider.availableTypes.map((t) => _typeChip(context, t, provider)),
                  ],
                ),
              ],
              SizedBox(height: 16),
              Text(AppLocalizations.of(context).sortBy,
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _sortOptions.map(((String, String) opt) {
                  final selected = provider.sortBy == opt.$2;
                  return FilterChip(
                    label: Text(opt.$1),
                    selected: selected,
                    onSelected: (_) => provider.setSortBy(opt.$2),
                    selectedColor: const Color(0xFFE8622A).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFFE8622A),
                    labelStyle: TextStyle(
                        color: selected ? const Color(0xFFE8622A) : Colors.white70, fontSize: 13),
                    backgroundColor: const Color(0xFF243347),
                    side: BorderSide(color: selected ? const Color(0xFFE8622A) : Colors.white12),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8622A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).apply, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _typeChip(BuildContext context, String? type, TrainingsProvider provider) {
    final selected = provider.selectedType == type;
    return FilterChip(
      label: Text(type ?? 'All'),
      selected: selected,
      onSelected: (_) => provider.setType(selected && type != null ? null : type),
      selectedColor: const Color(0xFF4A90D9).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF4A90D9),
      labelStyle: TextStyle(color: selected ? const Color(0xFF4A90D9) : Colors.white70, fontSize: 13),
      backgroundColor: const Color(0xFF243347),
      side: BorderSide(color: selected ? const Color(0xFF4A90D9) : Colors.white12),
    );
  }
}

class _Header extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onNotificationsTap;

  const _Header({required this.unreadCount, required this.onNotificationsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FitSync',
                style: TextStyle(
                  color: Color(0xFFE8622A),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(AppLocalizations.of(context).findYourTraining, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onNotificationsTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A3A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white70, size: 24),
                  if (unreadCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(color: Color(0xFFE8622A), shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RecommendedTraining training;
  final VoidCallback onTap;

  const _RecommendationCard({required this.training, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Review item 23: show the user why this training was recommended. The
    // backend sends a ready-made sentence, so the card only has to render it.
    final reason = training.reason;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8622A).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE8622A).withValues(alpha: 0.7),
                    const Color(0xFF4A90D9).withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.fitness_center, color: Colors.white60, size: 32)),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8622A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 10),
                          SizedBox(width: 2),
                          Text(AppLocalizations.of(context).pick,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    training.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        formatMoney(training.price),
                        style: const TextStyle(
                            color: Color(0xFFE8622A), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Spacer(),
                      if (training.averageRating != null) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          training.averageRating!.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.amber, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                  if (reason != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF4A90D9), size: 11),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10, height: 1.25),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final Training training;
  final VoidCallback onTap;

  const _TrainingCard({required this.training, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final diffColors = {
      TrainingDifficulty.beginner: Colors.green,
      TrainingDifficulty.intermediate: Colors.orange,
      TrainingDifficulty.advanced: Colors.red,
    };
    final diffColor = diffColors[training.difficulty] ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE8622A).withValues(alpha: 0.8),
                    const Color(0xFF4A90D9).withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(Icons.fitness_center,
                    color: Colors.white.withValues(alpha: 0.6), size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          training.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        formatMoney(training.price),
                        style: const TextStyle(
                            color: Color(0xFFE8622A), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (training.trainingTypeName != null) ...[
                    const SizedBox(height: 4),
                    Text(training.trainingTypeName!,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Chip(
                          icon: Icons.timer,
                          label: '${training.durationMinutes} min',
                          color: const Color(0xFF4A90D9)),
                      const SizedBox(width: 8),
                      _Chip(
                          icon: Icons.people,
                          label: AppLocalizations.of(context).spotsCount(training.maxCapacity),
                          color: Colors.purple),
                      const SizedBox(width: 8),
                      _Chip(
                          icon: Icons.trending_up,
                          label: training.difficulty.label,
                          color: diffColor),
                      const Spacer(),
                      if (training.averageRating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              training.averageRating!.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 48),
          SizedBox(height: 12),
          Text(error, style: TextStyle(color: Colors.grey[400]), textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text(AppLocalizations.of(context).retry)),
        ]),
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.fitness_center, color: Colors.grey[700], size: 64),
          SizedBox(height: 16),
          Text(AppLocalizations.of(context).noTrainingsFound, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ]),
      );
}

class _FilteredEmptyView extends StatelessWidget {
  final VoidCallback onClear;
  const _FilteredEmptyView({required this.onClear});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.filter_list_off, color: Colors.grey[600], size: 56),
          SizedBox(height: 12),
          Text(AppLocalizations.of(context).noTrainingsMatchFilters,
              style: TextStyle(color: Colors.grey[400], fontSize: 15)),
          SizedBox(height: 16),
          TextButton.icon(
            icon: Icon(Icons.clear, size: 16),
            label: Text(AppLocalizations.of(context).clearFilters),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE8622A)),
            onPressed: onClear,
          ),
        ]),
      );
}
