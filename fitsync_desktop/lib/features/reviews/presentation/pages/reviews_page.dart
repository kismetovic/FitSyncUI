import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/review.dart';
import '../providers/reviews_provider.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewsProvider>().loadReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsProvider>(
      builder: (context, provider, _) {
        final filtered = provider.reviews.where((r) {
          final q = _searchQuery.toLowerCase();
          return q.isEmpty ||
              (r.userName?.toLowerCase().contains(q) ?? false) ||
              (r.trainingName?.toLowerCase().contains(q) ?? false) ||
              (r.comment?.toLowerCase().contains(q) ?? false);
        }).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Reviews', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold,
                    )),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      onPressed: () => provider.loadReviews(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search reviews...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    filled: true,
                    fillColor: const Color(0xFF1E2A3A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
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
                      : filtered.isEmpty
                          ? _EmptyState()
                          : _ReviewsList(
                              reviews: filtered,
                              onDelete: (r) => _confirmDelete(context, provider, r),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ReviewsProvider provider, Review review) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: const Text('Delete Review', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete review by "${review.userName}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await provider.remove(review.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final List<Review> reviews;
  final void Function(Review) onDelete;

  const _ReviewsList({required this.reviews, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    return ListView.separated(
      itemCount: reviews.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = reviews[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A3A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE8622A).withValues(alpha: 0.15),
                child: Text(
                  (r.userName?.isNotEmpty == true) ? r.userName![0].toUpperCase() : '?',
                  style: const TextStyle(color: Color(0xFFE8622A), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          r.userName ?? 'Unknown',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 8),
                        Text(
                          r.trainingName ?? 'Unknown Training',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                        const Spacer(),
                        Text(fmt.format(r.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _StarRating(r.rating),
                    if (r.comment != null && r.comment!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(r.comment!, style: TextStyle(color: Colors.grey[300], fontSize: 14)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => onDelete(r),
                tooltip: 'Delete review',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  const _StarRating(this.rating);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) => Icon(
        i < rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 16,
      )),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.star_border, size: 64, color: Colors.grey[700]),
      const SizedBox(height: 16),
      Text('No reviews found', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
    ]),
  );
}
