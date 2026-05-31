import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../features/trainings/domain/entities/training.dart';
import '../providers/reviews_provider.dart';

class TrainingReviewsPage extends StatefulWidget {
  final Training training;

  const TrainingReviewsPage({super.key, required this.training});

  @override
  State<TrainingReviewsPage> createState() => _TrainingReviewsPageState();
}

class _TrainingReviewsPageState extends State<TrainingReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewsProvider>().loadReviews(widget.training.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          appBar: AppBar(
            backgroundColor: const Color(0xFF152030),
            foregroundColor: Colors.white,
            title: Text('Reviews – ${widget.training.name}'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.rate_review),
                onPressed: () => _showReviewDialog(context, provider),
                tooltip: 'Leave a review',
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8622A)))
              : provider.reviews.isEmpty
                  ? _EmptyState(onAddReview: () => _showReviewDialog(context, provider))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.reviews.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _ReviewCard(review: provider.reviews[i]),
                    ),
        );
      },
    );
  }

  void _showReviewDialog(BuildContext context, ReviewsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewForm(
        trainingId: widget.training.id,
        provider: provider,
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE8622A).withValues(alpha: 0.15),
                child: Text(
                  (review.userName?.isNotEmpty == true) ? review.userName![0].toUpperCase() : '?',
                  style: const TextStyle(color: Color(0xFFE8622A), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName ?? 'Anonymous',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text(fmt.format(review.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                )),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment!, style: TextStyle(color: Colors.grey[300], height: 1.5)),
          ],
        ],
      ),
    );
  }
}

class _ReviewForm extends StatefulWidget {
  final int trainingId;
  final ReviewsProvider provider;

  const _ReviewForm({required this.trainingId, required this.provider});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
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
                const Text('Leave a Review',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Rating', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                ),
              )),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: const Color(0xFF243347),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.provider.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(widget.provider.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8622A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: widget.provider.submitting ? null : _submit,
                child: widget.provider.submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final ok = await widget.provider.submitReview(
      trainingId: widget.trainingId,
      rating: _rating,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
    );
    if (ok && mounted) Navigator.pop(context);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddReview;
  const _EmptyState({required this.onAddReview});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.star_border, color: Colors.grey[700], size: 64),
      const SizedBox(height: 16),
      Text('No reviews yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
      const SizedBox(height: 8),
      Text('Be the first to leave a review!', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A), foregroundColor: Colors.white),
        onPressed: onAddReview,
      ),
    ]),
  );
}
