import 'package:flutter/material.dart';
import '../../domain/entities/training.dart';
import '../../domain/entities/training_difficulty.dart';
import '../../../reservations/presentation/pages/reservation_form_page.dart';
import '../../../reviews/presentation/pages/training_reviews_page.dart';
import '../../../../core/utils/money.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';

class TrainingDetailPage extends StatelessWidget {
  final Training training;

  const TrainingDetailPage({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    final diffColors = {
      TrainingDifficulty.beginner: Colors.green,
      TrainingDifficulty.intermediate: Colors.orange,
      TrainingDifficulty.advanced: Colors.red,
    };
    final diffColor = diffColors[training.difficulty] ?? Colors.grey;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF152030),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE8622A).withValues(alpha: 0.8),
                      const Color(0xFF4A90D9).withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.fitness_center, color: Colors.white54, size: 80),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              training.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (training.trainingTypeName != null)
                              Text(training.trainingTypeName!,
                                  style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                          ],
                        ),
                      ),
                      Text(
                        formatMoney(training.price),
                        style: const TextStyle(
                          color: Color(0xFFE8622A),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _InfoBadge(Icons.timer, '${training.durationMinutes} min', Colors.blue),
                      const SizedBox(width: 10),
                      _InfoBadge(Icons.people, AppLocalizations.of(context).spotsCount(training.maxCapacity), Colors.purple),
                      const SizedBox(width: 10),
                      _InfoBadge(Icons.trending_up, training.difficulty.label, diffColor),
                    ],
                  ),
                  if (training.averageRating != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          i < (training.averageRating!.round()) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        )),
                        const SizedBox(width: 8),
                        Text(
                          '${training.averageRating!.toStringAsFixed(1)} (${training.reviewCount ?? 0} reviews)',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                  if (training.description != null && training.description!.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Text(AppLocalizations.of(context).about, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(training.description!, style: TextStyle(color: Colors.grey[300], height: 1.6)),
                  ],
                  SizedBox(height: 20),
                  OutlinedButton.icon(
                    icon: Icon(Icons.star, size: 18),
                    label: Text(AppLocalizations.of(context).viewReviews),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber,
                      side: const BorderSide(color: Colors.amber),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrainingReviewsPage(training: training),
                      ),
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: Icon(Icons.calendar_month),
              label: Text(AppLocalizations.of(context).bookNow, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8622A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservationFormPage(training: training),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
