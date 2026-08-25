import 'package:flutter/material.dart';
import '../../../../core/pagination/paged_result.dart';
import '../../data/datasources/payments_remote_data_source.dart';
import '../../data/models/payment_summary.dart';
import '../../domain/entities/admin_payment.dart';

class AdminPaymentsProvider extends ChangeNotifier {
  final PaymentsRemoteDataSource dataSource;
  AdminPaymentsProvider({required this.dataSource});

  List<AdminPayment> _payments = [];
  List<AdminPayment> get payments => _payments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error] (TIME_CONFLICT, AVAILABILITY_OVERLAP, …),
  /// so the screen can print the rule in the user's language rather than the
  /// server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  /// Page metadata from the API's PagedResult (review item 22).
  int _page = 1;
  int get page => _page;

  int _pageSize = kDefaultPageSize;
  int get pageSize => _pageSize;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  /// Totals for the summary cards, aggregated by the database rather than by
  /// summing the rows this page happens to hold.
  PaymentSummary _summary = const PaymentSummary();
  PaymentSummary get summary => _summary;

  double get totalRevenue => _summary.totalRevenue;
  int get paypalCount => _summary.payPalCount;
  int get cashCount => _summary.cashCount;

  /// Held so paging keeps the active filter.
  String _query = '';

  /// A new search is a new result set, so it restarts at page one.
  Future<void> search(String term) {
    _query = term;
    return load(page: 1);
  }

  Future<void> load({int? page}) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      final paged = await dataSource.getPayments(
        page: page ?? _page,
        pageSize: _pageSize,
        query: _query.isEmpty ? null : _query,
      );
      _payments = paged.items;
      _page = paged.page;
      _pageSize = paged.pageSize;
      _totalCount = paged.totalCount;
    } catch (e) {
      _error = e.toString();
    }

    // The summary is a separate, cheap aggregate call. A failure here must not
    // hide the page that did load, so it is reported but not fatal.
    try {
      _summary = await dataSource.getSummary();
    } catch (e) {
      _error ??= e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
