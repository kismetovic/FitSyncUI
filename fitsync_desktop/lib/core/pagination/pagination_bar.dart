import 'package:flutter/material.dart';

/// Page navigation shown under every admin table.
///
/// Deliberately dumb: it renders the page metadata the API returned and reports
/// which page the user asked for. All slicing happens server-side.
class PaginationBar extends StatelessWidget {
  final int page;
  final int pageSize;
  final int totalCount;
  final bool isLoading;
  final void Function(int page) onPageChanged;

  const PaginationBar({
    super.key,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
    this.isLoading = false,
  });

  int get totalPages => pageSize <= 0 ? 0 : (totalCount + pageSize - 1) ~/ pageSize;
  bool get hasPrevious => page > 1;
  bool get hasNext => page < totalPages;

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) return const SizedBox.shrink();

    final first = ((page - 1) * pageSize) + 1;
    final last = (page * pageSize) > totalCount ? totalCount : page * pageSize;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Text(
            '$first-$last od $totalCount',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: hasPrevious ? Colors.white : Colors.white24,
            onPressed: (hasPrevious && !isLoading) ? () => onPageChanged(page - 1) : null,
            tooltip: 'Prethodna',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF243347),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Strana $page / ${totalPages == 0 ? 1 : totalPages}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: hasNext ? Colors.white : Colors.white24,
            onPressed: (hasNext && !isLoading) ? () => onPageChanged(page + 1) : null,
            tooltip: 'Sljedeća',
          ),
        ],
      ),
    );
  }
}
