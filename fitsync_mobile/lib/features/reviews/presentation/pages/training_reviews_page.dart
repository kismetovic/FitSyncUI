import 'package:flutter/material.dart';
import '../../../../../core/error/api_error_messages.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../features/trainings/domain/entities/training.dart';
import '../../../reservations/domain/entities/reservation.dart';
import '../../../reservations/presentation/providers/reservations_provider.dart';
import '../providers/reviews_provider.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';

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
            title: Text(AppLocalizations.of(context).reviewsFor(widget.training.name)),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.rate_review),
                onPressed: () => _showReviewDialog(context, provider),
                tooltip: AppLocalizations.of(context).leaveReview,
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

  /// The user's own completed reservation for this training, if there is one.
  /// Only such a reservation can be reviewed, so the form is offered only when one
  /// exists. The backend re-checks this independently.
  Reservation? _findReviewableReservation(BuildContext context) {
    final reservations = context.read<ReservationsProvider>().reservations;
    for (final reservation in reservations) {
      if (reservation.trainingId == widget.training.id && reservation.canBeReviewed) {
        return reservation;
      }
    }
    return null;
  }

  void _showReviewDialog(BuildContext context, ReviewsProvider provider) {
    final reservation = _findReviewableReservation(context);

    if (reservation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recenziju možete ostaviti tek nakon što odradite ovaj trening '
            'i uplata bude evidentirana.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewForm(
        reservationId: reservation.id,
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
  /// The attended reservation being reviewed. The backend derives the training and
  /// the author from it, so a review can never be written for someone else or for a
  /// session the user did not attend.
  final int reservationId;
  final ReviewsProvider provider;

  const _ReviewForm({required this.reservationId, required this.provider});

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
                Text(AppLocalizations.of(context).leaveReview,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(AppLocalizations.of(context).rating, style: TextStyle(color: Colors.white70, fontSize: 13)),
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
            SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).shareExperience,
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
                child: Text(apiErrorText(context, widget.provider.errorCode, widget.provider.error), style: const TextStyle(color: Colors.red, fontSize: 12)),
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
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(AppLocalizations.of(context).submitReview, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final ok = await widget.provider.submitReview(
      reservationId: widget.reservationId,
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
      SizedBox(height: 16),
      Text(AppLocalizations.of(context).noReviewsYet, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
      SizedBox(height: 8),
      Text(AppLocalizations.of(context).beFirstToReview, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      SizedBox(height: 20),
      ElevatedButton.icon(
        icon: Icon(Icons.rate_review),
        label: Text(AppLocalizations.of(context).writeReview),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A), foregroundColor: Colors.white),
        onPressed: onAddReview,
      ),
    ]),
  );
}
