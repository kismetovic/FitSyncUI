import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../domain/entities/reservation_report.dart';
import '../../domain/entities/revenue_report.dart';
import '../../domain/usecases/get_reservation_report.dart';
import '../../domain/usecases/get_revenue_report.dart';
import '../pdf/report_pdf_builder.dart';

/// Which of the two required reports is currently selected.
enum ReportKind {
  reservations,
  revenue;

  String get title => this == ReportKind.reservations
      ? 'Izvještaj o rezervacijama'
      : 'Izvještaj o uplatama i prihodima';

  String get fileNamePrefix =>
      this == ReportKind.reservations ? 'fitsync-rezervacije' : 'fitsync-prihodi';
}

class ReportsProvider extends ChangeNotifier {
  final GetReservationReport getReservationReport;
  final GetRevenueReport getRevenueReport;

  ReportsProvider({
    required this.getReservationReport,
    required this.getRevenueReport,
  });

  ReportKind _kind = ReportKind.reservations;
  ReportKind get kind => _kind;

  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime get from => _from;

  DateTime _to = DateTime.now().add(const Duration(days: 30));
  DateTime get to => _to;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error] (TIME_CONFLICT, AVAILABILITY_OVERLAP, …),
  /// so the screen can print the rule in the user's language rather than the
  /// server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  ReservationReport? _reservationReport;
  ReservationReport? get reservationReport => _reservationReport;

  RevenueReport? _revenueReport;
  RevenueReport? get revenueReport => _revenueReport;

  /// The rendered PDF, ready to preview, print or save.
  Uint8List? _pdfBytes;
  Uint8List? get pdfBytes => _pdfBytes;

  bool get hasReport => _pdfBytes != null;

  void setKind(ReportKind kind) {
    if (_kind == kind) return;
    _kind = kind;
    _clearResult();
    notifyListeners();
  }

  void setPeriod({DateTime? from, DateTime? to}) {
    if (from != null) _from = from;
    if (to != null) _to = to;
    // The dates must stay in order, otherwise the API rejects the request.
    if (_to.isBefore(_from)) _to = _from;
    _clearResult();
    notifyListeners();
  }

  /// Fetches the data from the API and renders it into a PDF. The desktop app does
  /// no aggregation of its own, so what is printed is exactly what the server
  /// computed from the database.
  Future<bool> generate() async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    _pdfBytes = null;
    notifyListeners();

    final params = ReportPeriodParams(from: _from, to: _to);

    try {
      if (_kind == ReportKind.reservations) {
        final result = await getReservationReport(params);
        return await result.fold(
          (failure) {
            _error = failure.message;
            _errorCode = failure.code;
            _isLoading = false;
            notifyListeners();
            return false;
          },
          (report) async {
            _reservationReport = report;
            _pdfBytes = await ReportPdfBuilder.buildReservationReport(report);
            _isLoading = false;
            notifyListeners();
            return true;
          },
        );
      }

      final result = await getRevenueReport(params);
      return await result.fold(
        (failure) {
          _error = failure.message;
          _errorCode = failure.code;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (report) async {
          _revenueReport = report;
          _pdfBytes = await ReportPdfBuilder.buildRevenueReport(report);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = 'Generisanje izvještaja nije uspjelo: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Opens the system print dialog.
  Future<void> printReport() async {
    final bytes = _pdfBytes;
    if (bytes == null) return;
    await Printing.layoutPdf(onLayout: (_) async => bytes, name: _fileName());
  }

  /// Hands the PDF to the OS so the user can save it wherever they want.
  Future<void> downloadReport() async {
    final bytes = _pdfBytes;
    if (bytes == null) return;
    await Printing.sharePdf(bytes: bytes, filename: _fileName());
  }

  String _fileName() {
    String stamp(DateTime d) =>
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    return '${_kind.fileNamePrefix}-${stamp(_from)}-${stamp(_to)}.pdf';
  }

  void _clearResult() {
    _pdfBytes = null;
    _reservationReport = null;
    _revenueReport = null;
    _error = null;
    _errorCode = null;
  }
}
