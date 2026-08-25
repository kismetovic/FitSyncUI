/// Mirrors the API's `PagedResult<T>`.
///
/// Review item 22: every list endpoint returns page metadata and the server caps
/// `PageSize` at 100. The admin app requests pages rather than pulling whole
/// tables, so a growing database does not turn into a growing payload.
class PagedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;

  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  const PagedResult.empty()
      : items = const [],
        page = 1,
        pageSize = 20,
        totalCount = 0;

  int get totalPages => pageSize <= 0 ? 0 : (totalCount + pageSize - 1) ~/ pageSize;
  bool get hasPrevious => page > 1;
  bool get hasNext => page < totalPages;

  /// Reads the envelope the API sends. [fromItem] maps each element.
  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    return PagedResult<T>(
      items: (json['items'] as List? ?? const [])
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

/// The cap the API enforces. Asking for more is clamped server-side.
const int kMaxPageSize = 100;

/// What the admin tables request by default.
const int kDefaultPageSize = 20;
